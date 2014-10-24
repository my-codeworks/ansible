# Ansible plays

Ansible plays for Chefsportalen AB / Simplex2 provisioning on DigitalOcean

## Use

Run `ansible-playbook -i hosts site.yml` to provision and set up the infrastructure on DigitalOcean.

This requires you to have a API key/client ID pair from v1 of DigitalOcean's API exported in your environment as DO_API_KEY and DO_CLIENT_ID respectively.