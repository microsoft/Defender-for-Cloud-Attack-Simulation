# Defender for Cloud Attack Simulation

This tool simulates attack scenarios commonly used in real-world attacks, such as:

- Secret reconnaissance
- Lateral movement
- Secrets gathering
- Crypto-mining activity
- Webshell invocation

**Note:** This tool does not perform any actual malicious activity or execute harmful binaries. All files and activities are benign and designed to cause no harm to your environment.

## Features
- Simulates various attack scenarios in Kubernetes environments.
- Generates alerts for scenarios to validate Defender for Containers' detection capabilities.
- Provides detailed simulation options through a Python-based CLI.

## Installation
### Prerequisites
Before using the simulation tool, ensure you have the following:

1. A user with admin permissions over the target Kubernetes cluster.
2. Defender for Containers enabled and the Defender sensor installed in the cluster. You can verify the sensor installation by running:

   ```bash
   kubectl get ds microsoft-defender-collector-ds -n kube-system
   ```

3. Helm client installed on your local machine.
4. Python version 3.7 or above installed.
5. The kubeconfig file pointing to your target cluster. For Azure Kubernetes Service (AKS), you can set it up using:

   ```bash
   az aks get-credentials --name [cluster-name] --resource-group [resource-group]
   ```

### Download the Tool
Download the simulation tool script using:

```bash
curl -O https://raw.githubusercontent.com/microsoft/Defender-for-Cloud-Attack-Simulation/refs/heads/main/simulation.py
```

## Usage
Run the simulation script to initiate attack simulations:

```bash
python simulation.py
```

You can choose specific attack scenarios or simulate all scenarios at once. The available attack scenarios and their expected alerts are:

| **Scenario**          | **Expected Alerts**                                                                 |
|------------------------|-------------------------------------------------------------------------------------|
| Reconnaissance         | Possible Web Shell activity detected, Suspicious Kubernetes service account operation detected, Network scanning tool detected |
| Lateral Movement       | Possible Web Shell activity detected, Access to cloud metadata service detected    |
| Secrets Gathering      | Possible Web Shell activity detected, Sensitive files access detected, Possible secret reconnaissance detected |
| Crypto Mining          | Possible Web Shell activity detected, Kubernetes CPU optimization detected, Command within a container accessed `ld.so.preload`, Possible Crypto miners download detected, A drift binary detected executing in the container |
| Web Shell              | Possible Web Shell activity detected                                               |

**Note:** While some alerts are triggered in near real-time, others may take up to an hour.

### Best Practices
- Run the simulation tool on a dedicated cluster without production workloads to avoid unnecessary alerts in production environments.

---

For detailed documentation and additional information, visit [Defender for Containers Simulation Tool Documentation](https://learn.microsoft.com/en-us/azure/defender-for-cloud/alerts-containers#kubernetes-alerts-simulation-tool).

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
