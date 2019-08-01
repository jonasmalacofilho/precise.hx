class Main {
	static function main()
	{
		var runner = new utest.Runner();

		runner.addCase(new FloatToolsTests());
		// runner.addCase(new FloatIntervalTests());

		utest.ui.Report.create(runner);
		runner.run();
	}
}
