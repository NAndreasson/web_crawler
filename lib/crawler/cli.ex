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
		{time, results_map} = :timer.tc(Crawler.Scheduler, :run, [url, count])
		IO.puts "Done in"
		IO.puts time

		save_results_to_file(results_map)
	end

	defp save_results_to_file(results_map) do
		# get formatted time eg 2014_04_28_084339
		current_time = format_current_time()

		{:ok, file} = File.open "results_" <> current_time, [:write]

		IO.binwrite file, "Results from crawl starting at meck\n\n"

		# get keys - which are crawled urls, remove :start atom though
		crawled_urls = Dict.keys( Dict.delete(results_map, :start) )

		Enum.each(crawled_urls, fn(crawled_url) ->
			IO.binwrite file, "From: " <> crawled_url <> "\n"

			urls_found_at_crawled_url = Dict.get(results_map, crawled_url)

			Enum.each(urls_found_at_crawled_url, fn(found_url) -> 
				IO.binwrite file, "- " <> found_url <> "\n"
			end)

		end)

		# # for each key print values

		# Enum.each(results, fn(result) -> 
		# 	IO.binwrite file, result <> "\n"
		# end)

		File.close file
	end

	defp format_current_time() do
		time = Timex.Date.now()

		Timex.DateFormat.format!(time, "{YYYY}_{0M}_{0D}_{0h24}{0m}{0s}")
	end

end