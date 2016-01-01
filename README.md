analytics-elixir
================

analytics-elixir is a non-supported third-party client for [Segment](https://segment.com)

## Install

Add the following to deps section of your mix.exs: `{:segment, github: "stueccles/analytics-elixir"}`

and then `mix deps.get`

## Usage

Start the Segment agent with your write_key from Segment
```
Segment.start_link("YOUR_WRITE_KEY")
```
There are then two ways to call the different methods on the API.
A basic way through `Segment.Analytics` or by passing a full Struct
with all the data for the API (allowing Context and Integrations to be set)

## Usage in Phoenix

This is how I add to a Phoenix project (may not be your preferred way)

1. Add the following to deps section of your mix.exs: `{:segment, github: "stueccles/analytics-elixir"}`
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
  write_key: "2iFFnRsCfi"
```
4. Start the segment agent as a child of the application in the application file under
the lib directory. In the children list add:
```
worker(Segment, [Application.get_env(:segment, :write_key)])
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

## Running tests

There are not many tests at the moment. But you can run a live test on your segment
account by running.
```
SEGMENT_KEY=yourkey mix test
```
