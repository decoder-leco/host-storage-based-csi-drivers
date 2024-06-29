# Placement

The probe is a statefulset deploying 7 replicas of one simple app, for each replica a different volume is provisioned.

The 7 pods are scheduled on a different cluster node using affinities:

```bash
vagrant@debian12:~/.probe$ kubectl -n topology-probe-tests get pod/whoami-0 -o wide
NAME       READY   STATUS    RESTARTS   AGE   IP           NODE                              NOMINATED NODE   READINESS GATES
whoami-0   1/1     Running   0          4m    10.244.6.8   k8s-cluster-decoderleco-worker4   <none>           <none>
vagrant@debian12:~/.probe$ kubectl -n topology-probe-tests get pod/whoami-1 -o wide
NAME       READY   STATUS    RESTARTS   AGE    IP           NODE                              NOMINATED NODE   READINESS GATES
whoami-1   1/1     Running   0          4m2s   10.244.5.5   k8s-cluster-decoderleco-worker3   <none>           <none>
vagrant@debian12:~/.probe$ kubectl -n topology-probe-tests get pod/whoami-2 -o wide
NAME       READY   STATUS    RESTARTS   AGE   IP           NODE                              NOMINATED NODE   READINESS GATES
whoami-2   1/1     Running   0          4m    10.244.4.6   k8s-cluster-decoderleco-worker7   <none>           <none>
vagrant@debian12:~/.probe$ kubectl -n topology-probe-tests get pod/whoami-3 -o wide
NAME       READY   STATUS    RESTARTS   AGE     IP           NODE                              NOMINATED NODE   READINESS GATES
whoami-3   1/1     Running   0          3m59s   10.244.1.5   k8s-cluster-decoderleco-worker2   <none>           <none>
vagrant@debian12:~/.probe$ kubectl -n topology-probe-tests get pod/whoami-4 -o wide
NAME       READY   STATUS    RESTARTS   AGE     IP           NODE                             NOMINATED NODE   READINESS GATES
whoami-4   1/1     Running   0          3m48s   10.244.7.5   k8s-cluster-decoderleco-worker   <none>           <none>
vagrant@debian12:~/.probe$ kubectl -n topology-probe-tests get pod/whoami-5 -o wide
NAME       READY   STATUS    RESTARTS   AGE     IP           NODE                              NOMINATED NODE   READINESS GATES
whoami-5   1/1     Running   0          3m46s   10.244.3.5   k8s-cluster-decoderleco-worker6   <none>           <none>
vagrant@debian12:~/.probe$ kubectl -n topology-probe-tests get pod/whoami-6 -o wide
NAME       READY   STATUS    RESTARTS   AGE     IP           NODE                              NOMINATED NODE   READINESS GATES
whoami-6   1/1     Running   0          3m45s   10.244.2.5   k8s-cluster-decoderleco-worker5   <none>           <none>
vagrant@debian12:~/.probe$ kubectl -n topology-probe-tests get all

```
