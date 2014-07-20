defmodule Crawler.CLI do

	@default_count 10

	@moduledoc """
	Handle the parsing of commands and the dispatching to the crawler		
	"""

	def run(argv) do
		argv
			|> parse_args
			|> process
	end

	@doc """
	argv can be either -h or --help

	Otherwise it is a url and an optional count

	Return tuple { url, count } or :help
	"""
	def parse_args(argv) do
		parse = OptionParser.parse(argv, switches: [ help: :boolean], aliases: [ h: :help ])

		case parse do
			{ [ help: true ], _, _ } ->
				:help

			{ _, [ url, count ], _ } ->
				{ url, String.to_integer(count) }

			{ _, [ url ], _ } ->
				{ url, @default_count }

			_ -> :help
		end
	end

	def process(:help) do
		IO.puts """
		 usage: <url> [count]
		"""
		System.halt(0)
	end

	def process({url, count}) do
		Crawler.Scheduler.run(url)
	end

end