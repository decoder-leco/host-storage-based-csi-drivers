# TopoLVM Provisioning

* <https://github.com/topolvm/topolvm/>
* <https://github.com/topolvm/topolvm/blob/main/docs/getting-started.md>
* <https://github.com/topolvm/topolvm/tree/main/charts/topolvm>
* <https://github.com/topolvm/topolvm/tree/main/example>


## ANNEX: the topolvm docker images

```bash
vagrant@debian12:~$ kubectl -n topolvm-system get all
NAME                                      READY   STATUS              RESTARTS   AGE
pod/topolvm-controller-5dff8859b8-kpxmp   0/5     ContainerCreating   0          8m35s
pod/topolvm-controller-5dff8859b8-zlbrv   0/5     ContainerCreating   0          8m35s
pod/topolvm-lvmd-0-2r249                  0/1     ImagePullBackOff    0          8m35s
pod/topolvm-lvmd-0-2s7n5                  0/1     ImagePullBackOff    0          8m35s
pod/topolvm-lvmd-0-gv8xr                  0/1     ImagePullBackOff    0          8m35s
pod/topolvm-lvmd-0-hlrwj                  0/1     ImagePullBackOff    0          8m35s
pod/topolvm-lvmd-0-l6zpq                  0/1     ImagePullBackOff    0          8m35s
pod/topolvm-lvmd-0-v47nk                  0/1     ImagePullBackOff    0          8m35s
pod/topolvm-lvmd-0-zcb6h                  0/1     ImagePullBackOff    0          8m35s
pod/topolvm-node-5thww                    0/3     ImagePullBackOff    0          8m35s
pod/topolvm-node-cptk2                    0/3     ImagePullBackOff    0          8m35s
pod/topolvm-node-d9lrs                    0/3     ImagePullBackOff    0          8m35s
pod/topolvm-node-gm79z                    0/3     ImagePullBackOff    0          8m35s
pod/topolvm-node-j7dws                    0/3     ImagePullBackOff    0          8m35s
pod/topolvm-node-k4g88                    0/3     ImagePullBackOff    0          8m35s
pod/topolvm-node-nvc2w                    0/3     ImagePullBackOff    0          8m35s

NAME                         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/topolvm-controller   ClusterIP   10.96.220.219   <none>        443/TCP   8m35s

NAME                            DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/topolvm-lvmd-0   7         7         0       7            0           <none>          8m35s
daemonset.apps/topolvm-node     7         7         0       7            0           <none>          8m35s

NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/topolvm-controller   0/2     2            0           8m35s

NAME                                            DESIRED   CURRENT   READY   AGE
replicaset.apps/topolvm-controller-5dff8859b8   2         2         0       8m35s
vagrant@debian12:~$ kubectl -n topolvm-system get pod/topolvm-lvmd-0-2r249 -o yaml | yq '.spec.containers[0].image'
"ghcr.io/topolvm/topolvm-with-sidecar:0.30.0"
vagrant@debian12:~$ kubectl -n topolvm-system get pod/topolvm-node-cptk2 -o yaml | yq '.spec.containers[0].image'
"ghcr.io/topolvm/topolvm-with-sidecar:0.30.0"
vagrant@debian12:~$ kubectl -n topolvm-system get pod/topolvm-controller-5dff8859b8-zlbrv -o yaml | yq '.spec.containers[0].image'
"ghcr.io/topolvm/topolvm-with-sidecar:0.30.0"
vagrant@debian12:~$

```
