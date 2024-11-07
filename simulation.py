# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

import subprocess
import time

TITLE = """
+++ Defender for Cloud Attack Simulation +++

This simulation creates two pods - attacker and victim
The attacker pod will execute the chosen scenario on the victim
"""
MENU = """
Available scenarios:
    1. Reconnaissance - Gather information about the cluster environment.
    2. Lateral Movement - Cluster to cloud.
    3. Secrets Gathering - Search for sensitive information in the victim pod.
    4. Cryptomining - Run a cryptominer on the victim pod.
    5. Webshell - Exploit a webshell on the victim pod (NOTE: the webshell is used in all scenarios).
    6. All - Run all scenarios.

"""
SCENARIOS = ["recon", "lateral-mov", "secrets", "crypto", "webshell", "all"]
HELM_CHART = "oci://ghcr.io/microsoft/defender-for-cloud/attacksimulation/mdc-simulation"
HELM_RELEASE = "mdc-simulation"
NAMESPACE = "mdc-simulation"
ATTACKER = "mdc-simulation-attacker"
VICTIM = "mdc-simulation-victim"


def delete_resources():
    subprocess.run(["helm", "uninstall", HELM_RELEASE])
    subprocess.run(["kubectl", "delete", "namespace", NAMESPACE])


def run_scenario(scenario):
    """Installs components using helm and shows scenario results."""
    # Install or update the helm chart
    print("Helm - creating simulation objects in namespace mdc-simulation...")
    try:
        existing_pod=subprocess.run(["kubectl", "get", "pod", ATTACKER, "-n", NAMESPACE], capture_output=True, text=True)
        if existing_pod.stdout:
            subprocess.run(["kubectl", "delete", "pod", ATTACKER, "-n", NAMESPACE], check=True, capture_output=True)
        subprocess.run(["helm", "upgrade", "--install",  HELM_RELEASE, HELM_CHART,
                        "--set", f"env.name={NAMESPACE}", "--set", f"scenario={scenario}"],
                        check=True, capture_output=True)
    except FileNotFoundError:
        print("Can't find Helm. Exiting")
        raise FileNotFoundError
    except subprocess.CalledProcessError as e:
        print("Failed to create Helm chart. Exiting")
        raise subprocess.CalledProcessError(returncode=e.returncode, cmd=e.cmd)

    print("Creating resources...")
    attacker_status = subprocess.run(["kubectl", "get", "pod", ATTACKER, "-n", NAMESPACE, "-o",
                                      r'jsonpath="{.status.phase}"'], capture_output=True, text=True)
    victim_status = subprocess.run(["kubectl", "get", "pod", VICTIM, "-n", NAMESPACE, "-o",
                                    r'jsonpath="{.status.phase}"'], capture_output=True, text=True)
    while '"Pending"' in (attacker_status.stdout, victim_status.stdout) :
        time.sleep(3)
        attacker_pending =  subprocess.run(["kubectl", "get", "pod", ATTACKER, "-n", NAMESPACE, "-o",
                                      r'jsonpath="{.status.containerStatuses[0].state.waiting.reason}"'], capture_output=True, text=True)
        victim_pending = subprocess.run(["kubectl", "get", "pod", VICTIM, "-n", NAMESPACE, "-o",
                                    r'jsonpath="{.status.containerStatuses[0].state.waiting.reason}"'], capture_output=True, text=True)
        attacker_status = subprocess.run(["kubectl", "get", "pod", ATTACKER, "-n", NAMESPACE, "-o",
                                      r'jsonpath="{.status.phase}"'], capture_output=True, text=True)
        victim_status = subprocess.run(["kubectl", "get", "pod", VICTIM, "-n", NAMESPACE, "-o",
                                    r'jsonpath="{.status.phase}"'], capture_output=True, text=True)

        if (attacker_status.stdout =='"Pending"'  and attacker_pending.stdout != '"ContainerCreating"') or (victim_status.stdout == '"Pending"'  and victim_pending.stdout != '"ContainerCreating"'):
            print(f"Failed to create one or more containers.\nAttacker container status: {attacker_pending.stdout},\nVictim container status: {victim_pending.stdout}.")
            raise Exception
 
    if '"Failed"' in (attacker_status.stdout, victim_status.stdout):
        print(f"Failed to create one or more pods.\nAttacker pod status: {attacker_status.stdout},\nVictim pod status: {victim_status.stdout}.")
        raise Exception

    # read the attack output
    print("Running the scenario...\n")
    try:
        subprocess.run(["kubectl", "logs", "-f", ATTACKER, "-n",  NAMESPACE], timeout=90)
    except subprocess.TimeoutExpired:
        print("Scenario did not complete successfully (timeout)")
        return
    last_line = subprocess.run(["kubectl", "logs", "--tail=1", ATTACKER, "-n", NAMESPACE],
                               text=True, capture_output=True)
    if last_line.stdout == "--- Simulation completed ---\n":
        print("\nScenario completed successfully.\n")
    else:
        print("Scenario did not complete successfully")


def start_simulation():
    print(MENU)
    user_choise = input("Select a scenario: ")
    
    while not (user_choise.isnumeric()) or not(int(user_choise) in range(1, len(SCENARIOS)+1 )):
        print("Invalid input")
        user_choise = input("Select a scenario: ")

    choise = int(user_choise)

    try:
        run_scenario(SCENARIOS[choise-1])
    except FileNotFoundError:
        return
    except Exception:
        release_status = subprocess.run(["helm", "status", HELM_RELEASE], capture_output=True)
        if release_status.returncode == 0:
            delete_resources()
        return

    again = input("Run another scenario?(Y/N): ")
    while again.upper() not in ["Y", "N"]:
        print("Invalid input")
        again = input("Run another scenario?(Y/N): ")
    if again.upper() == "Y":
        subprocess.run(["kubectl", "delete", "pod", ATTACKER, "-n", NAMESPACE], capture_output=True)
        start_simulation()
    else:
        input("Press Any Button to delete resources")
        delete_resources()


def main():
    print(TITLE)
    start_simulation()


if __name__ == '__main__':
    main()
