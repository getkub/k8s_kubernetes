##  Will include PostGres + N8N
Steps

```
kubectl -n n8n apply -f 01/.
kubectl -n n8n apply -f 02/.
kubectl -n n8n apply -f 03/.
```



## Clean-up Everything

```
kubectl -n n8n delete -f 03/.
kubectl -n n8n delete -f 02/.
kubectl -n n8n delete -f 01/.
```