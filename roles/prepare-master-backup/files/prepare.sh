 #!/bin/bash

BACKUP_DIR='/tmp/backup'
rm $BACKUP_DIR -r
mkdir $BACKUP_DIR

mkdir -p $BACKUP_DIR/etcd/tmp
ETCD_DATA_DIR='/var/lib/etcd'
etcdctl backup --data-dir $ETCD_DATA_DIR --backup-dir $BACKUP_DIR/etcd/tmp
mkdir -p $BACKUP_DIR/etcd/tmp/member/snap/db
cp "$ETCD_DATA_DIR"/member/snap/db $BACKUP_DIR/etcd/tmp/member/snap/db
cd $BACKUP_DIR/etcd/tmp
tar -cvzf $BACKUP_DIR/etcd/etcd.tar.gz *
rm $BACKUP_DIR/etcd/tmp -r


mkdir $BACKUP_DIR/backup_openshift_projects
cd $BACKUP_DIR/backup_openshift_projects

# Get Projects
oc get projects | grep -v "DISPLAY NAME" | awk '{print $1}' > $BACKUP_DIR/backup_openshift_projects/projects.txt

# Backup Projects
for project in $(cat projects.txt); do oc export all -n $project -o yaml > $BACKUP_DIR/backup_openshift_projects/$project.yaml; done

# Backup Role Bindings
for project in $(cat projects.txt); do oc get rolebindings -n $project -o yaml > $BACKUP_DIR/backup_openshift_projects/$project-rolebindings.yaml; done

# Backup Service Accounts
for project in $(cat projects.txt); do oc get serviceaccount -n $project -o yaml > $BACKUP_DIR/backup_openshift_projects/$project-serviceaccount.yaml; done

# Backup Secrets
for project in $(cat projects.txt); do oc get secret -n $project -o yaml > $BACKUP_DIR/backup_openshift_projects/$project-secret.yaml; done

# Backup PVC
for project in $(cat projects.txt); do oc get pvc -n $project -o yaml > $BACKUP_DIR/backup_openshift_projects/$project-pvc.yaml; done

# Backup PV
oc get pv -o yaml > $BACKUP_DIR/backup_openshift_projects/pv.yaml

#oc logout >> /dev/null
