# analytics-elixir

**_This fork intends to give the ability to instantiate more than one Segment Analytics instance. Let's say that a single Application requires to send analytics to more than one Segment Analytics (using different private keys)._**

analytics-elixir is a non-official third-party client for [Segment](https://segment.com). Since version `2.0` it supports
batch delivery of events and retries for the API.

## Installation

Add `segment` to your list of dependencies in mix.exs

```
def deps do
  [
    {:segment, "~> 0.2.3"}
  ]
end
```

## Documentation

Documentation can be be found at [https://hexdocs.pm/segment](https://hexdocs.pm/segment).

## Usage

Start the Segment agent with your write_key from Segment for a HTTP API Server Source

```elixir
Segment.start_link("YOUR_WRITE_KEY")
```

There are then two ways to call the different methods on the API.
A basic way through `Segment.Analytics` functions with either the full event Struct
or some helper methods (also allowing Context and Integrations to be set manually).

This way will use the defined GenServer implementation such as `Segment.Analytics.Batcher` which will
queue and batch events to Segment.

The other way is to drop down lower and use `Segment.Http` `send` and `batch` directly. This will require first creating a `client` with `Segment.Http.client/1`/`Segment.Http.client/2`

### Track

```elixir
Segment.Analytics.track(user_id, event, %{property1: "", property2: ""})
```

or the full way using a struct with all the possible options for the track call

```elixir
%Segment.Analytics.Track{ userId: "sdsds",
                          event: "eventname",
                          properties: %{property1: "", property2: ""}
                        }
  |> Segment.Analytics.track
```

### Identify

```elixir
Segment.Analytics.identify(user_id, %{trait1: "", trait2: ""})
```

or the full way using a struct with all the possible options for the identify call

```elixir
%Segment.Analytics.Identify{ userId: "sdsds",
                             traits: %{trait1: "", trait2: ""}
                           }
  |> Segment.Analytics.identify
```

### Screen

```elixir
Segment.Analytics.screen(user_id, name)
```

or the full way using a struct with all the possible options for the screen call

```elixir
%Segment.Analytics.Screen{ userId: "sdsds",
                           name: "dssd"
                         }
  |> Segment.Analytics.screen
```

### Alias

```elixir
Segment.Analytics.alias(user_id, previous_id)
```

or the full way using a struct with all the possible options for the alias call

```elixir
%Segment.Analytics.Alias{ userId: "sdsds",
                          previousId: "dssd"
                         }
  |> Segment.Analytics.alias
```

### Group

```elixir
Segment.Analytics.group(user_id, group_id)
```

or the full way using a struct with all the possible options for the group call

```elixir
%Segment.Analytics.Group{ userId: "sdsds",
                          groupId: "dssd"
                         }
  |> Segment.Analytics.group
```

### Page

```elixir
Segment.Analytics.page(user_id, name)
```

or the full way using a struct with all the possible options for the page call

```elixir
%Segment.Analytics.Page{ userId: "sdsds",
                         name:   "dssd"
                       }
  |> Segment.Analytics.page
```

### Using the Segment Context

If you want to set the Context manually you should create a `Segment.Analytics.Context` struct with `Segment.Analytics.Context.new/1`

```elixir
context = Segment.Analytics.Context.new(%{active: false})

Segment.Analytics.track(user_id, event, %{property1: "", property2: ""}, context)
```

## Configuration

The library has a number of configuration options you can use to overwrite default values and behaviours

- `config :segment, :sender_impl` Allows selection of a sender implementation. At the moment this defaults to `Segment.Analytics.Batcher` which will send all events in batch. Change this value to `Segment.Analytics.Sender` to have all messages sent immediately (asyncronously)
- `config :segment, :max_batch_size` The maximum batch size of messages that will be sent to Segment at one time. Default value is 100.
- `config :segment, :batch_every_ms` The time (in ms) between every batch request. Default value is 2000 (2 seconds)
- `config :segment, :retry_attempts` The number of times to retry sending against the segment API. Default value is 3
- `config :segment, :retry_expiry` The maximum time (in ms) spent retrying. Default value is 10000 (10 seconds)
- `config :segment, :retry_start` The time (in ms) to start the first retry. Default value is 100
- `config :segment, :send_to_http` If set to `false`, the libray will override the Tesla Adapter implementation to only log segment calls to `debug` but not make any actual API calls. This can be useful if you want to switch off Segment for test or dev. Default value is true
- `config :segment, :tesla, :adapter` This config option allows for overriding the HTTP Adapter for Tesla (which the library defaults to Hackney).This can be useful if you prefer something else, or want to mock the adapter for testing.

## Usage in Phoenix

This is how I add to a Phoenix project (may not be your preferred way)

1. Add the following to deps section of your mix.exs: `{:segment, "~> 0.2.0"}`
   and then `mix deps.get`
2. Add a config variable for your write_key (you may want to make this load from ENV)
   ie.

```elixir
config :segment,
  write_key: "2iFFnRsCfi"
```

3. Start the Segment GenServer in the supervised children list. In `application.ex` add to the children list:

```elixir
{Segment, Application.get_env(:segment, :write_key)}
```

## Running tests

There are not many tests at the moment. if you want to run live tests on your account you need to change the config in `test.exs` to `config :segment, :send_to_http, true` and then provide your key as an environment variable.

```
SEGMENT_KEY=yourkey mix test
```
