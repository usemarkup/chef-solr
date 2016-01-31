#!/usr/bin/env bats

@test "is solr running" {
    result="$(/etc/init.d/solr status | grep -i "no solr nodes are running" | wc -l)"
    [ "$result" -eq 0 ]
}
