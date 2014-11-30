# Zhihu Mercenaries Crawler

It is a crawler to find "praise mercenaries" on Zhihu.

## Dependencies

The program uses sqlite3 as its default database. You have to have it installed first.

Then, run `bundle install` to resolve dependencies. 

~~For performance reasons, you can replace sqlite3 with other databases you like.~~

~~**Remember to modify `db.rb` if you decide to use another database.**~~

## Initialization

You need to initial the crawler before using it.

Edit the seed problem url in `init.rb` and run it to finish initialization.

## Usage

Run `run.sh` to start the crawler.

~~You can interrupt the program at any time. Next time you start the program, it will resume from break point.~~

