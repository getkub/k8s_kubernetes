## Convert Docker compose with ENV values
```
docker-compose config
docker-compose config > converted_compose.yml && ./kompose -f converted_compose.yml convert

```