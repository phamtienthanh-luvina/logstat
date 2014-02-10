package activator;

import impl.LogStatImpl;

import org.osgi.framework.Bundle;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;

import service.LogStat;

public class Activator implements BundleActivator {

	@Override
	public void start(BundleContext context) throws Exception {
		// TODO Auto-generated method stub
		//Bundle bundle = FrameworkUtil.getBundle(Activator.class).getBundleContext().getBundle();
		Bundle bundle = context.getBundle();
        context.registerService(LogStat.class.getName(), new LogStatImpl(bundle), null);
        System.out.println("LogStat Service registered !");

	}

	@Override
	public void stop(BundleContext context) throws Exception {
		// TODO Auto-generated method stub
		
	}

}
