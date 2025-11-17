## RBAC Setup 

This guide explains how to create a namespace-scoped ServiceAccount,
Role, RoleBinding, and Token for Jenkins using Kubernetes RBAC best
practices.
This setup giving Jenkins access only within the `webapps` namespace.

------------------------------------------------------------------------

#### `jenkins-rbac.yaml`

Apply all resources using one combined manifest:

``` yaml
apiVersion: v1
kind: Namespace
metadata:
name: webapps
---
apiVersion: v1
kind: ServiceAccount
metadata:
name: jenkins
namespace: webapps
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
name: jenkins-deployer
namespace: webapps
rules:
  - apiGroups:
      - ""
      - apps
      - batch
      - networking.k8s.io     # only if needed
      - autoscaling           # only if needed
    resources:
      - pods
      - pods/log
      - deployments
      - replicasets
      - services
      - configmaps
      - secrets
      - jobs
      - cronjobs
      - ingresses             # only if using networking.k8s.io
      - horizontalpodautoscalers   # only if using autoscaling
    verbs:
      - get
      - list
      - watch
      - create
      - update
      - patch
      - delete
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
name: jenkins-deployer-binding
namespace: webapps
roleRef:
apiGroup: rbac.authorization.k8s.io
kind: Role
name: jenkins-deployer
subjects:
- kind: ServiceAccount
name: jenkins
namespace: webapps
---
apiVersion: v1
kind: Secret
metadata:
name: jenkins-token
namespace: webapps
annotations:
kubernetes.io/service-account.name: jenkins
type: kubernetes.io/service-account-token
```

(Use the full YAML from your canvas document.)

------------------------------------------------------------------------

### Apply the RBAC Resources

Run:

``` bash
kubectl apply -f jenkins-rbac.yaml
```

------------------------------------------------------------------------

### View the Secret Details

#### Option 1 --- Describe the secret

``` bash
kubectl -n webapps describe secret jenkins-token
```

#### Option 2 --- View full YAML

``` bash
kubectl -n webapps get secret jenkins-token -o yaml
```

------------------------------------------------------------------------

#### Extract the ServiceAccount Token

``` bash
kubectl -n webapps get secret jenkins-token -o jsonpath='{.data.token}' | base64 -d
```

This will print the **token string** that Jenkins will use for
authentication.

------------------------------------------------------------------------

### Summary

-   Namespace `webapps` created\
-   Jenkins ServiceAccount created\
-   Role with least-privilege permissions\
-   RoleBinding applied\
-   Token generated manually (Kubernetes 1.24+ behavior)\
-   Token used for Jenkins Kubernetes integration

