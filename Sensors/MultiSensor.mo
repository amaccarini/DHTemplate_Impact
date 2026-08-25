within DHTemplates.Sensors;
model MultiSensor
  "Measures selected quantities (flow, pressure, temperature etc.) and exposes them on a MultiSensorPort"
  extends Buildings.Fluid.Sensors.BaseClasses.PartialFlowSensor(final
      m_flow_nominal=1) annotation (IconMap(extent={{-100,-100},{100,100}},
        primitivesVisible=false));
  Interfaces.MultiSensorPort multiSensorPort annotation (Placement(
        transformation(extent={{-10,40},{10,60}}), iconTransformation(extent={{
            -20,30},{20,70}})));

  Medium.AbsolutePressure p(displayUnit="bar");
  Medium.Temperature T(displayUnit="degC");
  Medium.SpecificEnthalpy h(displayUnit="kJ/kg");
  SI.MassFlowRate m_flow;

  Modelica.Blocks.Sources.RealExpression p_expr(y=p)
    annotation (Placement(transformation(extent={{-60,20},{-40,40}})));
  Modelica.Blocks.Sources.RealExpression T_expr(y=T)
    annotation (Placement(transformation(extent={{-60,0},{-40,20}})));
  Modelica.Blocks.Sources.RealExpression m_flow_expr(y=m_flow)
    annotation (Placement(transformation(extent={{-60,-20},{-40,0}})));
  Modelica.Blocks.Sources.RealExpression h_expr(y=h)
    annotation (Placement(transformation(extent={{-60,-40},{-40,-20}})));
protected
  Medium.Temperature T_a_inflow "Temperature of inflowing fluid at port_a";
  Medium.Temperature T_b_inflow
    "Temperature of inflowing fluid at port_b or T_a_inflow, if uni-directional flow";
equation
  if allowFlowReversal then
    T_a_inflow = Medium.temperature(
      Medium.setState_phX(
        port_b.p,
        port_b.h_outflow,
        port_b.Xi_outflow));
    T_b_inflow = Medium.temperature(
      Medium.setState_phX(
        port_a.p,
        port_a.h_outflow,
        port_a.Xi_outflow));
    T = Modelica.Fluid.Utilities.regStep(
      port_a.m_flow,
      T_a_inflow,
      T_b_inflow,
      m_flow_small);

    h = Modelica.Fluid.Utilities.regStep(
      port_a.m_flow,
      port_b.h_outflow,
      port_a.h_outflow,
      m_flow_small);

  else
    T = Medium.temperature(
      Medium.setState_phX(
        port_b.p,
        port_b.h_outflow,
        port_b.Xi_outflow));
    T_a_inflow = T;
    T_b_inflow = T;

    h = port_b.h_outflow;
  end if;

  m_flow = port_a.m_flow;
  p = port_a.p;

  // Connect to port
  connect(p_expr.y, multiSensorPort.p) annotation (Line(points={{-39,30},{0.05,
          30},{0.05,50.05}}, color={0,0,127}));
  connect(T_expr.y, multiSensorPort.T) annotation (Line(points={{-39,10},{0.05,
          10},{0.05,50.05}}, color={0,0,127}));
  connect(m_flow_expr.y, multiSensorPort.m_flow) annotation (Line(points={{-39,
          -10},{0,-10},{0,50.05},{0.05,50.05}}, color={0,0,127}));
  connect(h_expr.y, multiSensorPort.h) annotation (Line(points={{-39,-30},{0.05,
          -30},{0.05,50.05}}, color={0,0,127}));

  annotation (
    defaultComponentPrefixes="protected",
    Documentation(revisions="<html>
<ul>
<li>
August 20, 2026, by Rene Just Nielsen:<br>
First implementation.
</li>
</ul>
</html>"),
    Icon(coordinateSystem(initialScale=0.04), graphics={
        Rectangle(
          extent={{-100,4},{102,-4}},
          lineColor={0,128,255},
          fillColor={0,128,255},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{32,-28},{60,-40},{32,-52},{32,-28}},
          lineColor={0,128,255},
          fillColor={0,128,255},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{32,-34},{48,-40},{32,-46},{32,-34}},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          lineColor={255,255,255}),
        Line(points={{60,-40},{-60,-40}}, color={0,128,255})}),
    Diagram(coordinateSystem(extent={{-100,-60},{100,60}}, grid={2,2})));
end MultiSensor;
