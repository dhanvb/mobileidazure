output "cloudamqp_intance_credentials" {
  value = { for credential in data.cloudamqp_credentials.credentials : credential.username => credential.password }
}

output "cloudamqp_instance_provider_data" {
  value = tomap({
    for key, value in local.instances : cloudamqp_instance.instances[key].tags[1] => {
      "instance_id" : cloudamqp_instance.instances[key].id
      "env" : cloudamqp_instance.instances[key].tags[1]
      "username" : data.cloudamqp_credentials.credentials[key].username
      "password" : data.cloudamqp_credentials.credentials[key].password
      "vhost" : data.cloudamqp_credentials.credentials[key].username
    }
  })
}

output "cloudamqp_instance_provider_url" {
  value = tomap({
    for key, value in local.instances : cloudamqp_instance.instances[key].tags[1] => {
      "instance_id" : cloudamqp_instance.instances[key].id
      "env" : cloudamqp_instance.instances[key].tags[1]
      "url" : cloudamqp_instance.instances[key].url
    }
  })
}