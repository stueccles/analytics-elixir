defmodule SegmentTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    ExVCR.Config.cassette_library_dir("test/fixtures/vcr_cassettes")
    Application.put_env(:segment, :write_key, System.get_env("SEGMENT_KEY"))
    HTTPoison.start()
    :ok
  end

  describe "Segment.track/4" do
    test "that track sends a request to segment and recieves a 200" do
      ExVCR.Config.filter_request_options("basic_auth")

      use_cassette "example_segment" do
        t = Segment.track("343434", "Test Event")
        Task.await(t)
      end
    end
  end
end
