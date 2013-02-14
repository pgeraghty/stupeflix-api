# stupeflix

Stupeflix API (http://developer.stupeflix.com/) wrapper using HTTParty.

## Installation

Add this line to your application's Gemfile:

    gem 'stupeflix'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stupeflix

## Usage

Retrieve your API keys from http://developer.stupeflix.com/keychain/ and then replace the placeholder variables below.

```ruby
s = Stupeflix.new YOUR_ACCESS_KEY, YOUR_SECRET_KEY, 'user/resource'
id = 'some_unique_identifier'

# To PUT a video definition
s.put_definition definition_xml, id

# POST profiles to request videos be generated accordingly
s.post_profiles profiles_xml, id

# GET status of requested videos
s.status id
```

Follow [this link](http://stupeflix-api.readthedocs.org/en/latest/resources/04_video_description_langage.html) for more
information about how to produce a definition. I recommend Nokogiri's XML builder.

An example of profile XML:
```xml
<profiles><profile name="720p"><stupeflixStore></stupeflixStore></profile></profiles>
```

Follow [this link](http://wiki.stupeflix.com/doku.php?id=profiles) for a list of supported profile types. Videos will be
generated for each profile.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
