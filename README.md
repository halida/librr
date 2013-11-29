# librr

## about

It's a tool to index & search your local directory text files,
It use [solr](http://lucene.apache.org/solr/) for fulltext index.

## guide

First you need to add a file or directory:

```sh
librr add ./gtd
```

Wait a while for librr daemon to index the files, and find something you interested:

```sh
librr search emacs
```

Then you got the results! librr will monitor file changes in this directories.

## install

**System Requirements**: OSX or linux, Java 1.6 or greater, ruby gem system.

```
gem install librr
```

## usage

Start and stop background monitor process:

```sh
librr daemon start
librr daemon stop
```

It will start up automatically after first call to `librr search`,
You don't need to start it manually.


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

## development

You can add `--debug` or `-d` argument to see what was happened under the hood: `librr add -d`.

And for debugging, you can run daemon sync with a terminal, and check the debug information on the stdout:

```
librr daemon start --sync -d
```

