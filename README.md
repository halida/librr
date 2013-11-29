# librr

## about

It's a tool to index & search your local directory text files,
It use [solr](http://lucene.apache.org/solr/) for fulltext index.

## guide

First you need to add a file or directory:

```sh
librr add
```

## install

**System Requirements**: OSX or linux, Java 1.6 or greater, ruby gem system.

```
gem install librr
```

## usage

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
```

Using search:

```sh
librr search emacs
~/Dropbox/sync/docs/emacs.org:26: xxx emacs
~/Dropbox/sync/docs/gtd.org:230: bbb emacs

# or using sortcut:
librr s emacs

# set return result rows(default 30):
librr search emacs --rows 100

# under directory:
librr search emacs --location ./gtd
librr search emacs -l ./gtd
```

Schecdule reindex:

```sh
librr reindex [dir]
```
