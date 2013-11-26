**It is a project which under heavy construction, please leave it alone!**

# librr

line based personal documentation search system

## about

It is a tool to to index & search your text based documentation system.
It use [solr](http://lucene.apache.org/solr/) for fulltext index.

## install

for debian based system:

```sh
sudo add-apt-repository ppa:librr
sudo apt-get install librr
```

for osx:

```
brew install librr
```

## usecases

Start and stop background monitor process:

```sh
librr start
librr stop
```

It will start up automatically after first call to `librr search`,
You don't need to start it manually.
The background process name is: `librrd` and also start solr process.

Config search directories:

```sh
librr add ~/Dropbox/sync/docs
librr remove ~/Dropbox/sync/b

librr list
~/Dropbox/sync/docs
...
```

Using search:

```sh
librr search emacs
~/Dropbox/sync/docs/emacs.org:26: xxx emacs
~/Dropbox/sync/docs/gtd.org:230: bbb emacs

# or using sortcut:
librr s emacs
```

TODO rows

Schecdule reindex:

```sh
librr reindex [dir]
```
