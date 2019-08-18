class Main {
	static function main()
	{
		var runner = new utest.Runner();

		runner.addCase(new FloatToolsTests());
		runner.addCase(new FloatIntervalTests());
		runner.addCase(new CurrencyTests());

		utest.ui.Report.create(runner);
		runner.run();
	}
}
