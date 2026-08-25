within DHTemplates.Components;
model HeatPump
  "Compression heat pump model with internal feed water pump. Controls outlet temperature and heat flow rate (positive) added to fluid."
  replaceable package Medium = Buildings.Media.Water "Medium in the component"
    annotation (choices(
      choice(redeclare package Medium = Buildings.Media.Air "Moist air"),
      choice(redeclare package Medium = Buildings.Media.Water "Water"),
      choice(redeclare package Medium =
            Buildings.Media.Antifreeze.PropyleneGlycolWater (property_T=293.15,
              X_a=0.40) "Propylene glycol water, 40% mass fraction")));
  parameter Modelica.Units.SI.MassFlowRate m_flow_nominal=abs(Q_flow_nominal/(
      cp_default*(T_b_nominal - T_a_nominal))) "Nominal mass flow rate"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.Units.SI.MassFlowRate m_flow_small(min=0) = 1E-4*abs(
    m_flow_nominal) "Small mass flow rate for regularization of zero flow"
    annotation (Dialog(tab="Advanced"));

  parameter Boolean allowFlowReversal=true
    "= false to simplify equations, assuming, but not enforcing, no flow reversal"
    annotation (Dialog(tab="Assumptions"), Evaluate=true);


  parameter SI.Power P_nominal(displayUnit="MW") = 13e6
    "Nominal electric power consumption"
    annotation (Dialog(group="Nominal condition"));
  parameter SI.HeatFlowRate Q_flow_nominal(displayUnit="MW") = 40e6
    "Nominal heat flow rate" annotation (Dialog(group="Nominal condition"));
  parameter SI.Temperature T_a_nominal=40 + 273.15 "Nominal inlet temperature"
    annotation (Dialog(group="Nominal condition"));
  parameter SI.Temperature T_b_nominal=90 + 273.15 "Nominal outlet temperature"
    annotation (Dialog(group="Nominal condition"));
  parameter SI.Temperature T_source_nominal=10 + 273.15
    "Nominal source temperature" annotation (Dialog(group="Nominal condition"));
  parameter SI.PressureDifference dp_nominal=5e4
    "Nominal (internal) pressure drop across heat source"
    annotation (Dialog(group="Nominal condition"));

  parameter SI.Temperature T_start=T_b_nominal "Start value of temperature"
    annotation (Dialog(tab="Initialization"));
  parameter SI.Time tau=0.632*pump.riseTime + heater.tau "Total time constant";
  // Heat flow rate control


  // Electric power control
  parameter Boolean powerControl=true
    "Power consumption given as setpoint (otherwise heat flow rate)"
    annotation (Dialog(group="Electic power control"));
  parameter Boolean use_P_set_in=true
    "True to use external heat flow rate setpoint"
    annotation (Dialog(group="Electic power control", enable=powerControl));
  replaceable Modelica.Blocks.Sources.Constant P_set(k=P_nominal)
    constrainedby Modelica.Blocks.Interfaces.SO(y(unit="W", displayUnit="MW"))
    "Power consumption setpoint" annotation (
    Dialog(group="Electic power control", enable=powerControl and not
          use_P_set_in),
    choicesAllMatching=true,
    Placement(transformation(extent={{-58,64},{-46,76}})));

  // Heat flow rate control
  parameter Boolean use_Q_flow_set_in=true
    "True to use external heat flow rate setpoint" annotation (Dialog(group="Heat flow rate control",
        enable=not powerControl));
  replaceable Modelica.Blocks.Sources.Constant Q_flow_set(k=Q_flow_nominal)
    constrainedby Modelica.Blocks.Interfaces.SO(y(unit="W", displayUnit="MW"))
    "Heat flow rate setpoint (negative for heating)" annotation (
    Dialog(group="Heat flow rate control", enable=not powerControl and not
          use_Q_flow_set_in),
    Placement(transformation(extent={{4,62},{16,74}})),
    choicesAllMatching=true);
  replaceable Buildings.Controls.Continuous.LimPID pid(
    k=abs(1/Q_flow_nominal*tau/tc),
    Ti=min(tau, 4*tc),
    u_s(unit="W", displayUnit="MW"),
    u_m(unit="W", displayUnit="MW")) "Heat flow rate controller" annotation (
      Dialog(group="Heat flow rate control"), Placement(transformation(extent={{
            -60,-40},{-40,-20}})));
  parameter SI.Time tc=10
    "Desired closed-loop time constant (SIMC tuning rule)"
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
        origin={-20,-50})),
    choicesAllMatching=true);


  // Source temperature
  parameter Boolean use_T_source_in=false
    "True to use source temperature input"
    annotation (Dialog(group="Source temperature"));
  replaceable Modelica.Blocks.Sources.Constant T_source(k=T_source_nominal)
    constrainedby Modelica.Blocks.Interfaces.SO(y(unit="K", displayUnit="degC"))
    "Source temperature" annotation (
    Dialog(group="Source temperature", enable=not use_T_source_in),
    Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=0,
        origin={-114,58})),
    choicesAllMatching=true);


  // Ports
  Modelica.Fluid.Interfaces.FluidPort_a port_a(
    redeclare final package Medium = Medium,
    m_flow(min=if allowFlowReversal then -Modelica.Constants.inf else 0),
    p(start=Medium.p_default),
    h_outflow(start=Medium.h_default, nominal=Medium.h_default),
    Xi_outflow(each nominal=0.01))
    "Fluid connector a (positive design flow direction is from port_a to port_b)"
    annotation (Placement(transformation(extent={{-110,-10},{-90,10}}),
        iconTransformation(extent={{-110,-10},{-90,10}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_b(
    redeclare final package Medium = Medium,
    m_flow(max=if allowFlowReversal then +Modelica.Constants.inf else 0),
    p(start=Medium.p_default),
    h_outflow(start=Medium.h_default, nominal=Medium.h_default),
    Xi_outflow(each nominal=0.01))
    "Fluid connector b (positive design flow direction is from port_a to port_b)"
    annotation (Placement(transformation(extent={{90,-10},{70,10}}),
        iconTransformation(extent={{110,-10},{90,10}})));
  Modelica.Blocks.Interfaces.RealInput P_set_in(unit="W", displayUnit="MW")
    if use_P_set_in and powerControl "Electric power setpoint" annotation (
      Placement(transformation(extent={{-60,42},{-40,62}}), iconTransformation(
          extent={{-140,-80},{-100,-40}})));
  Modelica.Blocks.Interfaces.RealInput T_set_in(unit="K", displayUnit="degC")
    if use_T_set_in "External outlet temperature setpoint" annotation (
      Placement(transformation(extent={{30,-60},{10,-40}}), iconTransformation(
          extent={{-140,40},{-100,80}})));
  Modelica.Blocks.Interfaces.RealInput Q_flow_set_in(unit="W", displayUnit="MW")
    if use_Q_flow_set_in and not powerControl "Heat flow rate setpoint"
    annotation (Placement(transformation(extent={{0,60},{20,40}}),
        iconTransformation(extent={{-140,-80},{-100,-40}})));
  Modelica.Blocks.Interfaces.RealInput T_source_in(unit="K", displayUnit="degC")
    if use_T_source_in "Heat source temperature (air, water etc.)" annotation (
      Placement(transformation(extent={{-110,46},{-90,26}}), iconTransformation(
          extent={{-140,-20},{-100,20}}, rotation=270)));


  Modelica.Units.SI.MassFlowRate m_flow(start=_m_flow_start) = port_a.m_flow
    "Mass flow rate from port_a to port_b (m_flow > 0 is design flow direction)";

  Modelica.Units.SI.PressureDifference dp(
    start=_dp_start,
    displayUnit="Pa") = port_a.p - port_b.p
    "Pressure difference between port_a and port_b";

  SI.HeatFlowRate Q_flow(displayUnit="MW") = m_flow*cp_default*(T_b.T - T_a.T)
    "Heat flow rate";
  SI.Power P(displayUnit="MW") = if powerControl then P2Q.u1 else Q_flow/cop.COP
    "Total electric power consumption";

protected
  final parameter Modelica.Units.SI.MassFlowRate _m_flow_start=0
    "Start value for m_flow, used to avoid a warning if not set in m_flow, and to avoid m_flow.start in parameter window";
  final parameter Modelica.Units.SI.PressureDifference _dp_start(displayUnit="Pa")
     = 0
    "Start value for dp, used to avoid a warning if not set in dp, and to avoid dp.start in parameter window";
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
  Buildings.Fluid.HeatExchangers.Heater_T heater(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    dp_nominal=dp_nominal,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    QMax_flow=1.1*Q_flow_nominal,
    T_start=T_start) "heater" annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=0,
        origin={20,0})));
  Buildings.Fluid.Movers.SpeedControlled_y pump(
    redeclare package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    per(pressure(V_flow={0,m_flow_nominal/rho_default,1.5*m_flow_nominal/
            rho_default}, dp={2*heater.dp_nominal,heater.dp_nominal,0})))
    "Feed water pump" annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={-20,0})));
  replaceable BaseClasses.COP_Carnot cop constrainedby BaseClasses.partial_COP(
    T_supply_nominal=T_b_nominal,
    T_return_nominal=T_a_nominal,
    T_source_nominal=T_source_nominal,
    COP_nominal=Q_flow_nominal/P_nominal) annotation (Placement(transformation(
          extent={{-60,20},{-40,40}})), choicesAllMatching=true);

  Buildings.Fluid.Sensors.TemperatureTwoPort T_a(redeclare package Medium =
        Medium, m_flow_nominal=m_flow_nominal) "Temperature at port_a"
    annotation (Placement(transformation(extent={{-90,-10},{-70,10}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort T_b(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    T_start=T_start) "Temperature at port_b"
    annotation (Placement(transformation(extent={{40,-10},{60,10}})));
  Modelica.Blocks.Logical.Switch switch1
    annotation (Placement(transformation(extent={{66,70},{86,50}})));
  Modelica.Blocks.Sources.BooleanExpression powerCtrl_expr(y=powerControl)
    "If true, electric power consumption is given as setpoint. Otherwise, DH production"
    annotation (Placement(transformation(extent={{34,70},{54,50}})));
  Modelica.Blocks.Math.Product P2Q annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-10,36})));
equation
  // Conditional connections
  if use_T_set_in then
    connect(T_set_in, heater.TSet) annotation (Line(points={{20,-50},{0,-50},{0,
            -8},{8,-8}}, color={0,0,127}));
  else
    connect(T_set.y, heater.TSet) annotation (Line(points={{-9,-50},{0,-50},{0,-8},
            {8,-8}}, color={0,0,127}));
  end if;

  if use_Q_flow_set_in and not powerControl then
    connect(Q_flow_set_in, switch1.u3) annotation (Line(points={{10,50},{26,50},
            {26,68},{64,68}}, color={0,0,127}));
  else
    connect(Q_flow_set.y, switch1.u3)
      annotation (Line(points={{16.6,68},{64,68}}, color={0,0,127}));
  end if;

  if use_P_set_in then
    connect(P_set_in, P2Q.u1) annotation (Line(points={{-50,52},{-30,52},{-30,42},
            {-22,42}}, color={0,0,127}));
  else
    connect(P_set.y, P2Q.u1) annotation (Line(points={{-45.4,70},{-30,70},{-30,42},
            {-22,42}}, color={0,0,127}));
  end if;

  if use_T_source_in then
    connect(T_source_in, cop.T_source)
      annotation (Line(points={{-100,36},{-62,36}}, color={0,0,127}));
  else
    connect(T_source.y, cop.T_source) annotation (Line(points={{-107.4,58},{-86,
            58},{-86,36},{-62,36}}, color={0,0,127}));
  end if;


  // Permanent connections
  connect(pid.u_m, heater.Q_flow) annotation (Line(points={{-50,-42},{-50,-70},{
          40,-70},{40,-8},{31,-8}}, color={0,0,127}));
  connect(heater.port_a, pump.port_b)
    annotation (Line(points={{10,0},{-10,0}}, color={0,127,255}));
  connect(port_a, T_a.port_a)
    annotation (Line(points={{-100,0},{-90,0}}, color={0,127,255}));
  connect(T_a.port_b, pump.port_a)
    annotation (Line(points={{-70,0},{-30,0}}, color={0,127,255}));
  connect(heater.port_b, T_b.port_a)
    annotation (Line(points={{30,0},{40,0}}, color={0,127,255}));
  connect(T_b.port_b, port_b)
    annotation (Line(points={{60,0},{80,0}}, color={0,127,255}));
  connect(pid.y, pump.y)
    annotation (Line(points={{-39,-30},{-20,-30},{-20,-12}}, color={0,0,127}));
  connect(cop.T_return, T_a.T)
    annotation (Line(points={{-62,30},{-80,30},{-80,11}}, color={0,0,127}));
  connect(cop.T_supply, T_b.T) annotation (Line(points={{-62,24},{-74,24},{-74,16},
          {50,16},{50,11}}, color={0,0,127}));
  connect(switch1.y, pid.u_s) annotation (Line(points={{87,60},{96,60},{96,-76},
          {-80,-76},{-80,-30},{-62,-30}}, color={0,0,127}));
  connect(powerCtrl_expr.y, switch1.u2)
    annotation (Line(points={{55,60},{64,60}}, color={255,0,255}));
  connect(P2Q.y, switch1.u1) annotation (Line(points={{1,36},{60,36},{60,52},{64,
          52}}, color={0,0,127}));
  connect(cop.COP, P2Q.u2)
    annotation (Line(points={{-39,30},{-22,30}}, color={0,0,127}));
  annotation (
    Icon(graphics={
        Rectangle(
          extent={{-100,100},{100,-100}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Line(points={{-50,-30},{-50,10}}, color={28,108,200}),
        Line(points={{40,-30},{40,10}}, color={28,108,200}),
        Line(points={{-50,30},{-50,70}}, color={238,46,47}),
        Line(points={{40,30},{40,70}}, color={238,46,47}),
        Text(
          extent={{-140,-140},{140,-180}},
          textColor={0,0,0},
          textString=DynamicSelect("", String(1e-6*Q_flow, format=".2f") + " MW")),
        Rectangle(
          extent={{-80,-30},{80,-38}},
          lineColor={28,108,200},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-80,78},{80,70}},
          lineColor={238,46,47},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{20,40},{60,0}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Line(points={{24,8},{32,38}}, color={0,0,0}),
        Line(points={{56,8},{48,38}}, color={0,0,0}),
        Polygon(
          points={{-60,40},{-40,40},{-60,0},{-40,0},{-60,40}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Text(
          extent={{-80,-50},{20,-90}},
          textColor={0,0,0},
          textString=if powerControl then "P" else "Q_flow",
          horizontalAlignment=TextAlignment.Left)}),
    Diagram(coordinateSystem(extent={{-100,-80},{100,80}}, grid={2,2})),
    Documentation(revisions="<html>
<ul>
<li>
June 19, 2026, by Rene Just Nielsen:<br>
First implementation.
</li>
</ul>
</html>"),
    experiment(StopTime=600, __Dymola_Algorithm="Dassl"));
end HeatPump;
