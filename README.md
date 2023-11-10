rails g model books user_id:integer title:string author:string year:integer
rake db:migrate
rails g nopio_scaffold:controller books
