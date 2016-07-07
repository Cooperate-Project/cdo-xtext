package net.winklerweb.cdoxtext.runtime;

public interface IStartStop {

	public void start();

	public void stop();

	public static final IStartStop NOP = new IStartStop() {
		
		@Override
		public void stop() {
			return;
		}

		@Override
		public void start() {
			return;
		}
	};
}
