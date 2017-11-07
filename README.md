analytics-elixir
================

analytics-elixir is a non-supported third-party client for [Segment](https://segment.com)

## Install

Add the following to deps section of your mix.exs: `{:segment, github: "stueccles/analytics-elixir"}`

and then `mix deps.get`

## Usage

Configure Segment with your write_key
```
config :segment, write_key: System.get_env("SEGMENT_WRITE_KEY")
```

There are then two ways to call the different methods on the API.
A basic way passing in arguments or by passing a full Struct
with all the data for the API (allowing Context and Integrations to be set)

## Usage in Phoenix

This is how I add to a Phoenix project (may not be your preferred way)

1. Add the following to deps section of your mix.exs: `{:segment, github: "stueccles/analytics-elixir"}`
   and then `mix deps.get`
2. Set the config variable for your write_key in your application
ie.
```
config :segment, write_key: "2iFFnRsCfi"
```
### Track
```
Segment.send_track(user_id, event, %{property1: "", property2: ""})
```
or the full way using a struct with all the possible options for the track call
```
%Segment.Track{ userId: "sdsds",
                          event: "eventname",
                          properties: %{property1: "", property2: ""}
                        }
  |> Segment.send_track
```

### Identify
```
Segment.send_identify(user_id, %{trait1: "", trait2: ""})
```
or the full way using a struct with all the possible options for the identify call
```
%Segment.Identify{ userId: "sdsds",
                             traits: %{trait1: "", trait2: ""}
                           }
  |> Segment.send_identify
```

### Screen
```
Segment.send_screen(user_id, name)
```
or the full way using a struct with all the possible options for the screen call
```
%Segment.Screen{ userId: "sdsds",
                           name: "dssd"
                         }
  |> Segment.send_screen
```

### Alias
```
Segment.send_alias(user_id, previous_id)
```
or the full way using a struct with all the possible options for the alias call
```
%Segment.Alias{ userId: "sdsds",
                          previousId: "dssd"
                         }
  |> Segment.send_alias
```

### Group
```
Segment.send_group(user_id, group_id)
```
or the full way using a struct with all the possible options for the group call
```
%Segment.Group{ userId: "sdsds",
                          groupId: "dssd"
                         }
  |> Segment.send_group
```

### Page
```
Segment.send_page(user_id, name)
```
or the full way using a struct with all the possible options for the page call
```
%Segment.Page{ userId: "sdsds",
                         name:   "dssd"
                       }
  |> Segment.send_page
```

## Running tests

There are not many tests at the moment. But you can run a live test on your segment
account by running.
```
SEGMENT_KEY=yourkey mix test
```
