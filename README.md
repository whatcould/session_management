This is a small library for adding common methods for basic login to a Rails app. There are methods to add to a User (has_secure_password, token generation, authenticate method, etc) and basic methods to add to your controller and view helpers (current_user, log_in, require_user, etc).

I found myself copying and pasting these methods exactly as written in multiple projects, and I didn't want the baggage of a full auth library.

```ruby
class User < ApplicationRecord
  include SessionManagement::User
end

class ApplicationController < ActionController::Base
  include SessionManagement::ApplicationController
end

```
