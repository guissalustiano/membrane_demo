require Logger
alias Membrane.Demo.RtspToHls

# rtsp_stream_url = "rtsp://localhost:8554/livestream"
rtsp_stream_url = "rtsp://admin:admin@videstra.ddns.net:8554/0"
output_path = "hls_output"
rtp_port = 60000

# Prepare a clean directory where output files will be put
File.rm_rf!(output_path)
File.mkdir_p(output_path)

pipeline_options = %{
  port: rtp_port,
  output_path: output_path,
  stream_url: rtsp_stream_url,
  parent_pid: self()
}

{:ok, _sup, _pid} = Membrane.Pipeline.start_link(RtspToHls.Pipeline, pipeline_options)

# Wait until first chunks of the stream become available
receive do
  :track_playable -> :ok
end

{:ok, _server} =
  :inets.start(:httpd,
    bind_address: ~c"localhost",
    port: 8008,
    document_root: ~c".",
    server_name: ~c"rtsp_to_hls",
    server_root: "/tmp"
  )

Logger.info("Playback available at http://localhost:8008/stream.html")

Process.sleep(:infinity)
