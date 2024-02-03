##  Will include PostGres + N8N
Create Steps

```
kubectl -n n8n apply -f 01/.
kubectl -n n8n apply -f 02/.
kubectl -n n8n apply -f 03/.
```

## Operations
- Exec
```
pod="n8n-0"
kubectl -n n8n exec -it $pod -c n8n -- /bin/sh
```

- Copy
```
pod="n8n-0"
touch /tmp/file1.txt
kubectl -n n8n cp /tmp/file1.txt $pod:/code/workflow/ -c n8n
kubectl -n n8n exec $pod -c n8n -- find /code/workflow/
```

## Clean-up Everything

```
kubectl -n n8n delete -f 03/.
kubectl -n n8n delete -f 02/.
kubectl -n n8n delete -f 01/.
```