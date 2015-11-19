##Demo for my "Elasticsearch: Beyond Basic Authentication" talk

* vagrant up
* vagrant ssh
* cd /vagrant
* ./setup_mit_krb.sh
 * Realm: EXAMPLE:COM
 * Host: localhost
* ./start_elasticsearch.sh &
* ./kerb_request.sh

Vagrant exposes the ports 9200 and 5601. Open firefox on your host system and type:

* https://localhost:9200/_logininfo?pretty

Access is denied. To get access via PKI authentication

* import pki-scripts/client.p12 into firefox and try again
* You should be authenticated as "Mister Spock"

To get access via kerberos copy the /etc/krb5.conf from the vagrant box to your host system and

* In Firefox ass "localhost" to allowed URLs like described [here](https://ping.force.com/Support/PingFederate/Integrations/How-to-configure-supported-browsers-for-Kerberos-NTLM)
* kinit luke@EXAMPLE.COM
* Password is: lukepwd
* Open https://localhost:9200/_logininfo?pretty
* You should be authenticated as "luke"
