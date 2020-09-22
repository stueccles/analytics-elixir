analytics-elixir
================

analytics-elixir is a non-supported third-party client for [Segment](https://segment.com)

## Install

Add the following to deps section of your mix.exs: `{:segment, github: "FindHotel/analytics-elixir"}`

and then `mix deps.get`

## Usage

Start the Segment agent with your write_key from Segment, and the endpoint.
The __endpoint__ is optional and if omitted, it defaults to `https://api.segment.io/v1/`.
```
Segment.start_link("YOUR_SEGMENT_KEY", "https://example.com/v1")
```
There are then two ways to call the different methods on the API.
A basic way through `Segment.Analytics` or by passing a full Struct
with all the data for the API (allowing Context and Integrations to be set)

## Usage in Phoenix

This is how I add to a Phoenix project (may not be your preferred way)

1. Add the following to deps section of your mix.exs: `{:segment, github: "FindHotel/analytics-elixir"}`
   and then `mix deps.get`

2. Add segment to applications list in the Phoenix project mix.exs
ie.
```
def application do
  [mod: {FormAndThread, []},
   applications: [:phoenix, :phoenix_html, :cowboy, :logger,
                  :phoenix_ecto, :postgrex, :segment]]
end
```

3. Add a config variable for your write_key (may want to make this environment dependent)
ie.
```
config :segment,
  key: "your_segment_key",
  endpoint: "https://api.segment.io/v1/"
```
The __endpoint__ is optional (as specified in the Usage section above).

4. Start the segment agent as a child of the application in the application file under
the lib directory. In the children list add:
```
{Segment, [Application.get_env(:segment, :key), Application.get_env(:segment, :endpoint)]}
```

### Track
```
Segment.Analytics.track(user_id, event, %{property1: "", property2: ""})
```
or the full way using a struct with all the possible options for the track call
```
%Segment.Analytics.Track{ userId: "sdsds",
                          event: "eventname",
                          properties: %{property1: "", property2: ""}
                        }
  |> Segment.Analytics.track
```

### Identify
```
Segment.Analytics.identify(user_id, %{trait1: "", trait2: ""})
```
or the full way using a struct with all the possible options for the identify call
```
%Segment.Analytics.Identify{ userId: "sdsds",
                             traits: %{trait1: "", trait2: ""}
                           }
  |> Segment.Analytics.identify
```

### Screen
```
Segment.Analytics.screen(user_id, name)
```
or the full way using a struct with all the possible options for the screen call
```
%Segment.Analytics.Screen{ userId: "sdsds",
                           name: "dssd"
                         }
  |> Segment.Analytics.screen
```

### Alias
```
Segment.Analytics.alias(user_id, previous_id)
```
or the full way using a struct with all the possible options for the alias call
```
%Segment.Analytics.Alias{ userId: "sdsds",
                          previousId: "dssd"
                         }
  |> Segment.Analytics.alias
```

### Group
```
Segment.Analytics.group(user_id, group_id)
```
or the full way using a struct with all the possible options for the group call
```
%Segment.Analytics.Group{ userId: "sdsds",
                          groupId: "dssd"
                         }
  |> Segment.Analytics.group
```

### Page
```
Segment.Analytics.page(user_id, name)
```
or the full way using a struct with all the possible options for the page call
```
%Segment.Analytics.Page{ userId: "sdsds",
                         name:   "dssd"
                       }
  |> Segment.Analytics.page
```

### Config as options

You can also pass the __endpoint__ and __key__ as options to the
`Segment.Analytics.call/2` along with the struct.
```
%Segment.Analytics.Track{ userId: "sdsds",
                          event: "eventname",
                          properties: %{property1: "", property2: ""}
                        }
  |> Segment.Analytics.call([key: "YOUR_SEGMENT_KEY", endpoint: "https://example.com/v1"])
```

With this approach the options take precedence over configurations stored in the Segment agent.

## Running tests

There are not many tests at the moment. But you can run a live test on your segment
account by running.
```
SEGMENT_KEY=yourkey mix test
```
