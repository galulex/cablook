#  CabLook-backend

Requirements:

* Ruby 2.4.0: https://www.ruby-lang.org/en/documentation/

* Ruby on Rails 5.1.3: http://guides.rubyonrails.org/

* PostgreSQL 9.5: https://www.postgresql.org/docs/

Architecture:

* dry-validation: http://dry-rb.org/gems/dry-validation/

## :arrow_up: How to Setup Repository

**Step 1:** Clone this repo with:
```
HTTPS:
git clone https://bitbucket.org/activebridge/cablook-backend.git
```
```
SSH:
git clone git@bitbucket.org:activebridge/cablook-backend.git
```

**Step 2:** Type `cd cablook-backend` in terminal to enter cloned folder in the current directory.

**Step 3:** Run `bundle exec bundle install` to install dependencies.

## :arrow_up: How to Setup Database

**Step 1:** Copy `config/secrets.yml.example` to `config/secrets.yml`
```
cp config/secrets.yml.example config/secrets.yml
```
and change database configurations:
```
database_url: postgres://user:password@host/database_name
```
**Step 2:** Run `sudo -u postgres psql` to enter postgres console. Then enter password to get an access.

**Step 3:** Run
```
create database cablook_development; create database cablook_test;
```
to create required postgres databases. You can check it's success with `\list`.

**Step 4:** Exit console with `\quit`. Run
```
bundle exec rails db:migrate && bundle exec rails db:migrate RAILS_ENV=test
```
to migrate relations in databases.

**Additional configuration**
To load seeds run console `rails c` and call:
```
load 'db/seeds.rb'
```

To clean database:
```
bundle exec rails db:reset
```
or
```
bundle exec rails db:clean
```

## :arrow_right: How to Run Application

Run `rails s` and open `http://localhost:3000/`.

Run `sidekiq`

## :arrow_up: How to Contribute

**Step 1:** Install gem Github Workflow:
```
gem install github_workflow
```

**Step 2:** Click Generate new token on GitHub: https://github.com/settings/tokens. Choose only `repo` checkbox. Copy newly generated token.

**Step 3:** Create file in application root:
```
.github.rb
```

**Step 4:** Open created file and save generated token:
```
{
 "oauth_token": "TOKEN",
 "user_and_repo": "activebridge/cablook-backend"
}
```

**Step 5:** Create and start issue:
```
github_workflow create_and_start -m, --name=NAME
```

**Step 6:** Create branch named with issue number and issue title:
```
github_workflow start -i, --issue-id=ISSUE_ID
```

**Step 7:** Push branch to origin and convert Issue to Pull Request:
```
github_workflow push_and_pr
```

## :taco: How to update vendors prices

**Step 1:** Edit local JSON file in `cablook/public`.

**Step 2:** Open edit link and replace content with information from JSON file.

**Step 3:** Enter security key and save changes.

**Step 3:** Commit and push local changes

**McDonalds:**

View: https://json.extendsclass.com/bin/6a654d47e2ce

Edit: https://extendsclass.com/jsonstorage/6a654d47e2ce

**Lviv Croissants:**

View: https://json.extendsclass.com/bin/3518bd9b1b02

Edit: https://extendsclass.com/jsonstorage/3518bd9b1b02

**Doner Kebab:**

View: https://json.extendsclass.com/bin/dd3449edceb0

Edit: https://extendsclass.com/jsonstorage/dd3449edceb0

**Mishiko:**

View: https://json.extendsclass.com/bin/762ad4924f4c

Edit: https://extendsclass.com/jsonstorage/762ad4924f4c

**Klara Zakharivna**

View: https://json.extendsclass.com/bin/37a3ab49e7ad
Edit: https://extendsclass.com/jsonstorage/37a3ab49e7ad

Security key: `C@bL0ok2020`
