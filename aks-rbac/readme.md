#  RBAC for AKS

This charts enable readonly, write or full access to the defined namespace.


## Values

```yaml
nameOverride: ""
fullnameOverride: ""

# array of security group ids for which role will be given in the namespace
securityGroupIDs: #[]
  - XXXXXXXX


# access to namespace readonly|write|full
# readonly - can list,get,watch, get logs all resources
# write - can manage all resources, wihtout executing to pod
# full - write + can execute
access: readonly
```

## Example

set acces for groups defined in values.yaml in default namespace

```bash
helm install aplication-devo-rbac sdx/aks-rbac -f values.yaml -n default
```
