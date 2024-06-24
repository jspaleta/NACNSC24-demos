
## Tested Setup
docker talos cluster using 10.5.0.0/24 subnet for talos nodes
Install talos 3+ node cluster, 1 control plane.

## Order of operations tested

1. Build talos cluster using the cilium-prep.patch
2. Make sure kubectl is configured with talos cluster context
3. Label 1 worker node used for deathstar service deployment as firewall=cilium
ex: kubectl label node/talos-default-worker-1 firewall=cilium

3. Setup Blocking Talos Ingress Firewall using default-block.patch for all other nodes
adjust subnet as needed

4. Install cilium v1.15.5 using cilium-helm-values.html, adjust devices value for primary node eth device

5. Adjust k8s/cilium-l2lb-services.yaml for correct subnet for ip pool used for loadbalancer services. Avoid conflicts with cluster and dhcp range on subnet.

6. Apply k8s/cilium-l2lb-services.yaml

7. Install k8s/workload.yaml that 
Includes deathstar-lb and deathstar-np services, with node affinity deployment matching firewall=cilium.
Includes tiefighter deployment with node affinity for firewall!=cilium

8. Confirm deathstar LoadBalancer and NodePort services are operational on cluster host subnet (ex: Loadbalancer service has 10.5.0.100)

9. Confirm Deathstar NodePort service is reachable on all cluster nodes across cluster host subnet ( ex 10.5.0.0/24) even with Talos ingress active. 
Why is that? Cilium has assumed control of network policy for the ip addresses it understands to be "in cluster", even all the way to the exposed host devices. Cilium takes an allow by default stance in v1.15 (new option coming in v1.16 to deny by default)  

10. Confirm cilium health service is unreachable across cluster host subnet curl http://node-ip:4240/hello will fail for the nodes without the firewall=cilium label. The netfitler firewall Talos configures is still in control of the host network on the nodes.

11. Apply Cilium clusterwide network policy targeting all nodes labeled with firewall=cilium   ccnp/default-worker-node-host-firewall.yaml
12. Confirm the health service is port 4240 is no longer reachable on any node.
13. Now add CCNP to allow cilium agent health from outside the cluster
14. Confirm access to health endpoint on nodes without Talos ingress firewall running.
15. Reconfirm deathstar service is still reachable from outside the cluster.
16. Add CCNP to restrict all namespaces from outside the cluster by default based on Cilium entities.
17. Confirm outside access is restricted but internal cluster access is still available.
18. Now add CNP for default namespace to open deathstar service from outside the cluster.
19. Confirm deathstar is now reachable from outside the cluster.
20. Note CCNP has two modes, matching nodes (host firewall ingress)  or matching endpoints (traditional cluster network policy applied to all namespaces).

12. Apply Cilium 


9. Apply
