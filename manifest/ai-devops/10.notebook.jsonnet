function (    
    is_offline="false",
    private_registry="172.22.6.2:5000",    
    custom_domain_name="tmaxcloud.org",    
    tmax_client_secret="tmax_client_secret",
    hyperauth_url="172.23.4.105",
    hyperauth_realm="tmax",
    console_subdomain="console",    
    gatekeeper_log_level="info",    
    gatekeeper_version="v1.0.2"
)

local target_registry = if is_offline == "false" then "" else private_registry + "/";
[
    {
        "apiVersion": "v1",
        "data": {
            "CLIENT_SECRET": tmax_client_secret,
            "DISCOVERY_URL": std.join("", ["https://", hyperauth_url, "/auth/realms/", hyperauth_realm]),
            "CUSTOM_DOMAIN": custom_domain_name,
            "GATEKEEPER_VERSION": gatekeeper_version,
            "LOG_LEVEL": gatekeeper_log_level,
        },
        "kind": "ConfigMap",
        "metadata": {
            "labels": {
            "app": "notebook-controller",
            "app.kubernetes.io/component": "notebook-controller",
            "app.kubernetes.io/name": "notebook-controller",
            "kustomize.component": "notebook-controller"
            },
            "name": "notebook-controller-config",
            "namespace": "kubeflow"
        }
    },
    {
        "apiVersion": "apps/v1",
        "kind": "Deployment",
        "metadata": {
            "labels": {
            "app": "notebook-controller",
            "app.kubernetes.io/component": "notebook-controller",
            "app.kubernetes.io/name": "notebook-controller",
            "kustomize.component": "notebook-controller",
            "name": "notebook-controller-deployment",
            "notebook": "controller"
            },
            "name": "notebook-controller-deployment",
            "namespace": "kubeflow"
        },
        "spec": {
            "replicas": 1,
            "selector": {
            "matchLabels": {
                "app": "notebook-controller",
                "app.kubernetes.io/component": "notebook-controller",
                "app.kubernetes.io/name": "notebook-controller",
                "kustomize.component": "notebook-controller",
                "notebook": "controller"
            }
            },
            "strategy": {
            "type": "Recreate"
            },
            "template": {
            "metadata": {
                "labels": {
                "app": "notebook-controller",
                "app.kubernetes.io/component": "notebook-controller",
                "app.kubernetes.io/name": "notebook-controller",
                "kustomize.component": "notebook-controller",
                "notebook": "controller"
                },
                "name": "notebook-controller"
            },
            "spec": {
                "containers": [
                {
                    "env": [
                    {
                        "name": "CLIENT_SECRET",
                        "valueFrom": {
                        "configMapKeyRef": {
                            "key": "CLIENT_SECRET",
                            "name": "notebook-controller-config"
                        }
                        }
                    },
                    {
                        "name": "DISCOVERY_URL",
                        "valueFrom": {
                        "configMapKeyRef": {
                            "key": "DISCOVERY_URL",
                            "name": "notebook-controller-config"
                        }
                        }
                    },
                    {
                        "name": "CUSTOM_DOMAIN",
                        "valueFrom": {
                        "configMapKeyRef": {
                            "key": "CUSTOM_DOMAIN",
                            "name": "notebook-controller-config"
                        }
                        }
                    },
                    {
                        "name": "GATEKEEPER_VERSION",
                        "valueFrom": {
                        "configMapKeyRef": {
                            "key": "GATEKEEPER_VERSION",
                            "name": "notebook-controller-config"
                        }
                        }
                    },
                    {
                        "name": "LOG_LEVEL",
                        "valueFrom": {
                        "configMapKeyRef": {
                            "key": "LOG_LEVEL",
                            "name": "notebook-controller-config"
                        }
                        }
                    }
                    ],
                    "image": std.join("", [target_registry,"docker.io/tmaxcloudck/notebook-controller-go:b0.2.7"]),
                    "imagePullPolicy": "Always",
                    "name": "notebook-controller",
                    "volumeMounts": [
                    {
                        "mountPath": "/var/run/secrets/kubernetes.io/serviceaccount",
                        "name": "notebook-controller-service-account-token",
                        "readOnly": true
                    }
                    ]
                }
                ],
                "volumes": [
                {
                    "name": "notebook-controller-service-account-token",
                    "secret": {
                    "defaultMode": 420,
                    "secretName": "notebook-controller-service-account-token"
                    }
                }
                ]
            }
            }
        }
    }
]