defmodule CliTest do
	use ExUnit.Case

	import Crawler.CLI, only: [ parse_args: 1 ]

	test ":help returned by option parsing with -h or --help options" do
		assert parse_args(["-h", "anything"]) == :help 
		assert parse_args(["--help", "anything"]) == :help 
	end

	test "two values returned if two given" do
		assert parse_args(["http://google.se", "9"]) == { "http://google.se", 9} 
	end	

	test "two values returned if one given" do
		assert parse_args(["http://google.se"]) == {"http://google.se", 10}
	end
end