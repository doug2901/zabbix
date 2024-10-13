#!/bin/bash

# Commands
ECHO=$( whereis echo | awk '{print $2}' )
RM=$( whereis rm | awk '{print $2}' )
CAT=$( whereis cat | awk '{print $2}' )
GREP=$( whereis grep | awk '{print $2}' )
CUT=$( whereis cut | awk '{print $2}' )
SED=$( whereis sed | awk '{print $2}' )
EGREP=$( whereis egrep | awk '{print $2}' )
TAR=$( whereis tar | awk '{print $2}' )
MYSQLDUMP=$( whereis mysqldump | awk '{print $2}' )
FIND=$( whereis find | awk '{print $2}' )
SORT=$( whereis sort | awk '{print $2}' )
HEAD=$( whereis head | awk '{print $2}' )
AWK=$( whereis awk | awk '{print $2}' )
DATE=$( date +%F_%H-%M )

# Paramanters
DIRECTORY='/data/backup/'
FQDN=$( hostname -f )
ZABBIX="zabbix"


# Check autentication

        if [ ! $user ]; then
                user=$( $CAT /root/.my.cnf | $EGREP -i 'user' | $CUT -d= -f2 | $SED -r "s/\s?[';]*//g" )
        fi

        if [ ! $host ]; then
                host=$( $CAT /root/.my.cnf | $EGREP -i 'host' | $CUT -d= -f2 | $SED -r "s/\s?[';]*//g" )
        fi

        if [ ! $password ]; then
                password=$( $CAT /root/.my.cnf | $EGREP -i 'password' | $CUT -d= -f2 | $SED -r "s/\s?[';]*//g" )
        fi

        if [ $? -ne 0 ]; then
                exit 1
        fi



backup_db_zabbix ()
{


        STARTTIME=$( date +"%Y-%m-%d %T" )
        FSTARTTIME=${STARTTIME/ /-}

        $ECHO "Create backup database Zabbix_Reposts"
        $ECHO ""

        #Backup database Zabbix
        $MYSQLDUMP zabbix --max_allowed_packet=512M --add-drop-table --add-locks --extended-insert --single-transaction \
        --routines -quick --host=$host --user=$user --password=$password -v | xz > $DIRECTORY/DatabaseBackupZabbix-$DATE.db.xz

        if [ $? -ne 0 ]; then
                exit 1
        fi


}

backup_db_reports ()
{

        $ECHO "Create backup database Zabbix_Reposts"
        $ECHO ""

        #Backup database Zabbix Reports
        $MYSQLDUMP zabbix_reports --max_allowed_packet=512M --add-drop-table --add-locks --extended-insert --single-transaction \
        --routines -quick --host=$host --user=$user --password=$password -v | xz > $DIRECTORY/DatabaseBackupZabbix_reports-$DATE.db.xz

        if [ $? -ne 0 ]; then
                exit 1
        fi


        FINISHTIME=$( date +"%Y-%m-%d %T" )
        FFINISHTIME=${FINISHTIME/ /-}

}

sending_zabbix()
{

        $ECHO "Sending Backup Values to Zabbix..."
  $ECHO ""

        DURATION=$(( $(date -ud "$FINISHTIME" +%s) - $(date -ud "$STARTTIME" +%s) ))
        FILESIZE=$(du -s $DIRECTORY/DatabaseBackupZabbix-$DATE.db.xz | awk '{ printf ("%.0f\n", 0 + $1 * 1024)}')


        if (( $FILESIZE > 1048576 )); then
                zabbix_sender -z $ZABBIX -s $FQDN -k bkpSuccess -o 1
        else
                zabbix_sender -z $ZABBIX -s $FQDN -k bkpSuccess -o 0
        fi

        zabbix_sender -z $ZABBIX -s $FQDN -k bkpStart -o $FSTARTTIME
        zabbix_sender -z $ZABBIX -s $FQDN -k bkpFinish -o $FFINISHTIME
        zabbix_sender -z $ZABBIX -s $FQDN -k bkpDuration -o $DURATION
        zabbix_sender -z $ZABBIX -s $FQDN -k bkpFileSize -o $FILESIZE


        $ECHO "Done!"
        $ECHO ""

}


rotate_db_zabbix ()
{

        FILE=$( $FIND $DIRECTORY -maxdepth 1 -name "DatabaseBackupZabbix-*" -type f -printf '%T+ %p\n' | $SORT | $HEAD -n -3 | $AWK '{print $2}' )
        if [ ! -z "$FILE" ]; then
                $RM $FILE
        fi
}

rotate_db_reports ()
{

        FILE=$( $FIND $DIRECTORY -maxdepth 1 -name "DatabaseBackupZabbix_reports-*" -type f -printf '%T+ %p\n' | $SORT | $HEAD -n -3 | $AWK '{print $2}' )
        if [ ! -z "$FILE" ]; then
                $RM $FILE
        fi
}
main()
{
        backup_db_zabbix
        backup_db_reports
	sending_zabbix
        rotate_db_zabbix
        rotate_db_reports
}

# call main function

main

