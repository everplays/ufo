---
title: ufo current
reference: true
---

## Usage

    ufo current SERVICE

## Description

Switch the current service. Saves to `.ufo/current`

Sets a current service to remember so you do not have to provide the service name all the time.  This shortens the commands

    ufo ship hi-web # before
    ufo current --service hi-web
    ufo ship # after

The state information is written to `.ufo/current`.

## Examples

### service

To set current service:

    ufo current --service hi-web
    ufo current --service hi-worker
    ufo current --service demo-web

To view current service, run `ufo current` without any arguments.

    $ ufo current
    Current service: hi-web

To remove current service:

    ufo current --service ''

### env-extra

To also set a current `UFO_ENV_EXTRA`.

    ufo current --env-extra 1

The extra env setting will be reflected:

    $ ufo current
    Current service: hi-web
    Current env_extra: 1

The `UFO_ENV_EXTRA` variable takes higher precedence than the current setting in the saved file.

To unset:

    ufo current --env-extra ''

### services

The ufo ships command builds one docker image and deploys it to multiple ECS services. You can also have ufo remember what services to use with the current command.

    ufo current --services hi-web hi-worker
    ufo ships # will depoy to both hi-web and hi-worker

### rm all

To remove all current settings use the `--rm` option.

    ufo current --rm


## Options

```
[--rm], [--no-rm]            # Remove all current settings. Removes `.ufo/current`
[--service=SERVICE]          # Sets service as a current setting.
[--services=one two three]   # Sets services as a current setting. This is used for ufo ships.
[--env-extra=ENV_EXTRA]      # Sets UFO_ENV_EXTRA as a current setting.
[--verbose], [--no-verbose]  
[--mute], [--no-mute]        
[--noop], [--no-noop]        
[--cluster=CLUSTER]          # Cluster.  Overrides .ufo/settings.yml.
```
