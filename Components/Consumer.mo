within DHTemplates.Components;
model Consumer
  "DH consumer model with internal control valve. Controls outlet temperature and heat flow rate (negative) extracted from fluid."
  extends Buildings.Fluid.Interfaces.PartialTwoPortInterface(m_flow_nominal=abs(
        Q_flow_nominal/(cp_default*(T_b_nominal - T_a_nominal))));

  parameter SI.HeatFlowRate Q_flow_nominal(displayUnit="MW") = -40e6
    "Nominal heat flow rate" annotation (Dialog(group="Nominal condition"));
  parameter SI.Temperature T_a_nominal=90 + 273.15 "Nominal inlet temperature"
    annotation (Dialog(group="Nominal condition"));
  parameter SI.Temperature T_b_nominal=40 + 273.15 "Nominal outlet temperature"
    annotation (Dialog(group="Nominal condition"));
  parameter SI.PressureDifference dp_nominal=1e5 "Nominal pressure drop"
    annotation (Dialog(group="Nominal condition"));

  // Heat flow rate control
  parameter Boolean use_Q_flow_set_in=false
    "True to use external heat flow rate setpoint"
    annotation (Dialog(group="Heat flow rate control"));
  replaceable Modelica.Blocks.Sources.Constant Q_flow_set(k=Q_flow_nominal)
    constrainedby Modelica.Blocks.Interfaces.SO(y(unit="W", displayUnit="MW"))
    "Heat flow rate setpoint (negative for heating)" annotation (
    Dialog(group="Heat flow rate control"),
    Placement(transformation(extent={{-100,-40},{-80,-20}})),
    choicesAllMatching=true);
  replaceable Buildings.Controls.Continuous.LimPID pid(
    k=abs(1/Q_flow_nominal*tau/tc),
    Ti=min(tau, 4*tc),
    u_s(unit="W", displayUnit="MW"),
    u_m(unit="W", displayUnit="MW"),
    reverseActing=false) "Heat flow rate controller" annotation (Dialog(group=
          "Heat flow rate control"), Placement(transformation(extent={{-50,-40},
            {-30,-20}})));
  parameter SI.Time tc=5 "Desired closed-loop time constant (SIMC tuning rule)"
    annotation (Dialog(group="Heat flow rate control"));

  // Temperature control
  parameter Boolean use_T_set_in=false
    "True to use external outlet temperature setpoint"
    annotation (Dialog(group="Temperature control"));
  replaceable Modelica.Blocks.Sources.Constant T_set(k=T_b_nominal)
    constrainedby Modelica.Blocks.Interfaces.SO(y(unit="K", displayUnit="degC"))
    "Outlet temperature setpoint" annotation (
    Dialog(group="Temperature control", enable=not use_T_set_in),
    Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-50,40})),
    choicesAllMatching=true);

  SI.HeatFlowRate Q_flow(displayUnit="MW") = m_flow*cp_default*(T_b.T - T_a.T)
    "Heat flow rate";

  parameter SI.Temperature T_start=T_b_nominal "Start value of temperature"
    annotation (Dialog(tab="Initialization"));

  parameter SI.Time tau=0.632*valve.strokeTime + cooler.tau
    "Total time constant";
protected
  parameter Medium.SpecificHeatCapacity cp_default=
      Medium.specificHeatCapacityCp(
      Medium.setState_pTX(
        Medium.p_default,
        Medium.T_default,
        Medium.X_default)) "Default isobaric specific heat capacity";
  parameter Medium.Density rho_default=Medium.density_pTX(
      Medium.p_default,
      Medium.T_default,
      Medium.X_default) "Default density";
public
  Buildings.Fluid.HeatExchangers.SensibleCooler_T cooler(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    dp_nominal=0,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    QMin_flow=Q_flow_nominal,
    T_start=T_start) "Cooler" annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=0,
        origin={38,0})));
  Buildings.Fluid.Actuators.Valves.TwoWayLinear valve(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    dpValve_nominal=0.75*dp_nominal,
    strokeTime=30,
    y_start=0,
    dpFixed_nominal=0.25*dp_nominal) "Valve" annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={-10,0})));

  Modelica.Blocks.Interfaces.RealInput T_set_in(unit="K", displayUnit="degC")
    if use_T_set_in "External outlet temperature setpoint" annotation (
      Placement(transformation(extent={{-80,50},{-40,90}}), iconTransformation(
          extent={{-140,40},{-100,80}})));
  Modelica.Blocks.Interfaces.RealInput Q_flow_set_in(unit="W", displayUnit="MW")
    if use_Q_flow_set_in "External heat flow rate setpoint" annotation (
      Placement(transformation(extent={{-120,-90},{-80,-50}}),
        iconTransformation(extent={{-140,-80},{-100,-40}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort T_a(redeclare package Medium =
        Medium, m_flow_nominal=m_flow_nominal) "Temperature at port_a"
    annotation (Placement(transformation(extent={{-80,-10},{-60,10}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort T_b(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    T_start=T_start) "Temperature at port_b"
    annotation (Placement(transformation(extent={{60,-10},{80,10}})));
equation
  // Conditional connections
  if use_T_set_in then
    connect(T_set_in, cooler.TSet) annotation (Line(points={{-60,70},{12,70},{
            12,-8},{26,-8}}, color={0,0,127}));
  else
    connect(T_set.y, cooler.TSet) annotation (Line(points={{-39,40},{12,40},{12,
            -8},{26,-8}}, color={0,0,127}));
  end if;

    if use_Q_flow_set_in then
    connect(Q_flow_set_in, pid.u_s) annotation (Line(points={{-100,-70},{-60,-70},
            {-60,-30},{-52,-30}}, color={0,0,127}));
  else
    connect(Q_flow_set.y, pid.u_s)
      annotation (Line(points={{-79,-30},{-52,-30}}, color={0,0,127}));
  end if;

  // Permanent connections
  connect(pid.u_m, cooler.Q_flow) annotation (Line(points={{-40,-42},{-40,-60},
          {60,-60},{60,-8},{49,-8}}, color={0,0,127}));
  connect(cooler.port_a, valve.port_b)
    annotation (Line(points={{28,0},{0,0}}, color={0,127,255}));

  connect(port_a, T_a.port_a)
    annotation (Line(points={{-100,0},{-80,0}}, color={0,127,255}));
  connect(T_a.port_b, valve.port_a)
    annotation (Line(points={{-60,0},{-20,0}}, color={0,127,255}));
  connect(cooler.port_b, T_b.port_a)
    annotation (Line(points={{48,0},{60,0}}, color={0,127,255}));
  connect(T_b.port_b, port_b)
    annotation (Line(points={{80,0},{100,0}}, color={0,127,255}));
  connect(pid.y, valve.y)
    annotation (Line(points={{-29,-30},{-10,-30},{-10,-12}}, color={0,0,127}));
  annotation (
    Icon(graphics={
        Rectangle(
          extent={{-100,100},{100,-100}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-60,60},{60,-60}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Text(
          extent={{-140,160},{140,120}},
          textColor={0,0,0},
          textString=DynamicSelect("", String(1e-6*Q_flow, format=".2f") +
              " MW")),
        Ellipse(extent={{-40,40},{40,-40}}, lineColor={0,0,0})}),
    Diagram(coordinateSystem(extent={{-100,-80},{100,80}}, grid={2,2})),
    Documentation(revisions="<html>
<ul>
<li>
April 27, 2026, by Rene Just Nielsen:<br>
First implementation.
</li>
</ul>
</html>"),
    experiment(StopTime=600, __Dymola_Algorithm="Dassl"));
end Consumer;
