# vm_benchmark
Usage:
1. Enter the specific folder(Cloud provider) you want to test.
2. Change the variables such authentication / configration informations.
3. Create resources and run the test:
- Initialization terraform: `terraform init`
- Preview of the changes: `terraform plan`
- Apply changes: `echo yes | terraform apply`
4. Delete resources: `echo yes | terraform destroy`
