# SDK Usage

## Load library

```sh
$ source functions.sh
```

## Functions

### create_replication_controller

```sh
$ create_replication_controller <NAME> <IMAGE> <CONFIG> <SSH_PUBLIC_KEY>
```

### read_replication_controller

```sh
$ read_replication_controller <NAME>
```

### update_replication_controller

```sh
$ update_replication_controller NAME=<NAME> [IMAGE=<IMAGE>] [CONFIG=<CONFIG>] [REPLICAS=<REPLICAS>]
```

### delete_replication_controller

```sh
$ delete_replication_controller <NAME>
```

### revert_replication_controller

```sh
$ revert_replication_controller <NAME>
```

### read_pod

```sh
$ read_pod <NAME>
```

### update_pod

```sh
$ update_pod NAME=<NAME> [IMAGE=<IMAGE>] [CONFIG=<CONFIG>]
```

### delete_pod

```sh
$ delete_pod <NAME>
```

### revert_pod

```sh
$ revert_pod <NAME>
```
