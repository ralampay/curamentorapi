# CuraMentor API

An API for the CuraMentorl system.

## Tech Stack

* Database: `PostgreSQL`
* Rails: `8.1`

## Environment Variables

Copy `.dotenv.env` to `.env`

* `APP_NAME`: The name of your application. Will be used in database naming convention.
* `DB_USERNAME`: Database username
* `DB_PASSWORD`: Database password
* `DB_HOST`: Host location of database
* `DB_PORT`: Port of PostgreSQL
* `AWS_SQS_VECTORIZE_QUEUE`: URL of the FIFO queue used for publication vectorization

## Other Commands

**Fix Collation**

```bash
bundle exec rake db:refresh_collation_concurrent
```
