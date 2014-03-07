package impl;

import java.util.HashMap;
import org.jruby.embed.LocalContextScope;
import org.jruby.embed.LocalVariableBehavior;
import org.jruby.embed.ScriptingContainer;
import org.jruby.embed.osgi.OSGiScriptingContainer;
import org.osgi.framework.Bundle;

import service.LogStat;
import lib.Common;
/**
 * Implement of LogStat service
 * @author nguyenxuanluong
 *
 */
public class LogStatImpl implements LogStat{
	Bundle bundle;
	public LogStatImpl(Bundle bundle){
		this.bundle = bundle;
	}

	/**
	 * Monitoring logs
	 * @param args : An array of paramters
	 */
	public String runLogStat(HashMap<String,Object> conf) {
		String finalData = "";
		try {
			// Get default values
			HashMap<String, Object> mapDefaultInput = new HashMap<String, Object>();
			HashMap<String, Object> mapDefaultOutput = new HashMap<String, Object>();
			Common common = new Common();
			HashMap<String, Object> mapDefault = common.getInputConfig();
			mapDefaultInput = (HashMap<String, Object>) mapDefault.get("input");
			mapDefaultOutput = (HashMap<String, Object>) mapDefault.get("output");
			
			// Ruby process
			LogStatBean bean = new LogStatBean();
			ScriptingContainer container = new OSGiScriptingContainer(this.bundle,LocalContextScope.CONCURRENT,LocalVariableBehavior.PERSISTENT);
			container.setHomeDirectory("classpath:/META-INF/jruby.home");
			System.out.println("LogStartService Running ...");

			bean.setConfig(conf);
			container.put("bean", bean);
			container.put("mapDefaultInput", mapDefaultInput);
			container.put("mapDefaultOutput", mapDefaultOutput);
			container.runScriptlet("require 'ruby/ProcessInput.rb'");
			container.runScriptlet("require 'ruby/ProcessFilter.rb'");
			container.runScriptlet("require 'ruby/ProcessOutput.rb'");
			//Get input logs from source
			container.runScriptlet("pi = ProcessInput.new");
			container.runScriptlet("puts mapDefaultOutput");
			container.runScriptlet("bean.setInput(pi.getInputData((bean.getConfig)['input'], mapDefaultInput))");
			
			//Filter logs
			container.runScriptlet("pf = ProcessFilter.new");
			container.runScriptlet("filter_type = (bean.getConfig)['filter']['filter_type']");
			container.runScriptlet("filter_conf = (bean.getConfig)['filter']['filter_conf']");
			container.runScriptlet("bean.setOutput(pf.filter(filter_type, filter_conf, bean.getInput))");
			//Output logs
			container.runScriptlet("po = ProcessOutput.new");
			container.runScriptlet("dataFromOutput = po.output(bean.getOutput,(bean.getConfig)['output'], mapDefaultOutput)");
			if (container.get("dataFromOutput") != null ) {
				finalData = (String) container.get("dataFromOutput");
			}
			System.out.println("LogStartService Completed ...");
		} catch (Exception ex) {
			ex.printStackTrace();
		}
		return finalData;
	}
	//Bean to store logstat information (input-output data & configuration)
	public class LogStatBean {
		public Object getInput() {
			return input;
		}
		public void setInput(Object input) {
			this.input = input;
		}
		public Object getOutput() {
			return output;
		}
		public void setOutput(Object output) {
			this.output = output;
		}
		public HashMap<String,Object> getConfig() {
			return config;
		}
		public void setConfig(HashMap<String,Object> config) {
			
			this.config = config;
		}
		Object input;
		Object  output;
		public HashMap<String,Object> config;
		
	}
}