# DESCRIPTION:

This chef cookbook is designed to install [Solr](http://lucene.apache.org/solr/) 5.3+ and run it as a standalone service. Tested on Centos 6.4 only but should run on other Linux distros.

This cookbook does not configure solr cores, schema.xml, solrconfig.xml etc.

## REQUIREMENTS:

Java

## ATTRIBUTES:

### Version/Download Attributes

version: Will change the version of SOLR to install. Must be 5.3.0 or higher.
link: The remote path to download the solr tar file from
checksum: The sha256 checksum of the tar file
download: The path to download the tar file to before extraction

```ruby
default["solr"]["version"] = "5.3.0"
default["solr"]["link"] = "http://archive.apache.org/dist/lucene/solr/#{node['solr']['version']}/solr-#{node['solr']['version']}.tgz"
default["solr"]["checksum"] = "26aec63d81239a65f182f17bbf009b1070f7db0bb83657ac2a67a08b57227f7c" #sha256
default["solr"]["download"] = "/var/chef"
```

### Installation Attributes
Each of these attributes is passed into the solr installation script 'install_solr_service.sh'. See [the solr documentation](https://cwiki.apache.org/confluence/display/solr/Taking+Solr+to+Production#TakingSolrtoProduction-RuntheSolrInstallationScript) for more information:

```ruby
default["solr"]["install"] = "/opt"
default["solr"]["directory"] = "/var/solr"
default["solr"]["port"] = "8983"
default["solr"]["service"] = "solr"
default["solr"]["user"] = "solr"
```

### Configuration Attributes
Each of these attributes alter solr envrionment configuration options located (by default) in /var/solr/solr.in.sh. See [the solr documentation](https://cwiki.apache.org/confluence/display/solr/Taking+Solr+to+Production#TakingSolrtoProduction-RuntheSolrInstallationScript) for more information:

None of these are required but it makes sense to set these to your OS approprate locations. If these are set then chef will ensure the directory exists with appropriate permissions.

pidfile_path: Change the path that the pid file is saved to.
log_path: Change the path that log files are saved to.
home_path: Change the solr home (date directory) path.

```ruby
default["solr"]["pidfile_path"] = nil
default["solr"]["log_path"] = nil
default["solr"]["home_path"] = nil
```
