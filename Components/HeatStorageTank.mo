within DHTemplates.Components;
model HeatStorageTank "Stratified heat storage tank"

  // General tab
  replaceable package Medium = Modelica.Media.Interfaces.PartialMedium
    "Medium in the component" annotation (choices(
      choice(redeclare package Medium = Buildings.Media.Air "Moist air"),
      choice(redeclare package Medium = Buildings.Media.Water "Water"),
      choice(redeclare package Medium =
            Buildings.Media.Antifreeze.PropyleneGlycolWater (property_T=293.15,
              X_a=0.40) "Propylene glycol water, 40% mass fraction")));
  parameter Integer nSeg=20 "Number of segments";

  // General tab, nominal condition group
  parameter SI.MassFlowRate m_flow_nominal=Q_flow_nominal/(cp_nominal*(
      T_nominal - T_reference)) "Nominal mass flow rate"
    annotation (Dialog(group="Nominal condition"));
  parameter SI.Energy E_nominal = 3.6e11
    "Storage capacity with reference to nominal temperatures (positive for hot storage, negative for cold storage)"
    annotation (Dialog(group="Nominal condition"));

  parameter SI.HeatFlowRate Q_flow_nominal(displayUnit="MJ/s") = 50e6
    "Maximum charge/discharge rate"
    annotation (Dialog(group="Nominal condition"));
  parameter SI.Temperature T_nominal=90 + 273.15
    "Temperature at which energy contents is zero"
    annotation (Dialog(group="Nominal condition"));
  parameter SI.Temperature T_reference=40 + 273.15
    "Temperature at which energy contents is zero"
    annotation (Dialog(group="Nominal condition"));


  // Advanced tab
  parameter SI.MassFlowRate m_flow_small(min=0) = 1E-4*abs(m_flow_nominal)
    "Small mass flow rate for regularization of zero flow"
    annotation (Dialog(tab="Advanced"));
  parameter Boolean use_presurizer=true
    "Option to set system reference pressure by heat storage tank"
    annotation (Dialog(tab="Advanced", group="Static pressure"));
  parameter SI.Pressure p_static=1e5 + rho_nominal*Modelica.Constants.g_n*tank.hTan
    "Static pressure given by tank height"
    annotation (Dialog(tab="Advanced", group="Static pressure"));


  // Initialization tab
  parameter Boolean use_E_start=true
    "True to specify normalized, initial energy contents"
    annotation (Dialog(tab="Initialization"));
  parameter Real E_start(
    min=0,
    max=1) = 0.5 "Normalized initial energy contents"
    annotation (Dialog(tab="Initialization", enable=use_E_start));
  parameter SI.Temperature T_start[nSeg]=cat(1, fill(T_nominal, integer(nSeg*
      E_start)), fill(T_reference, nSeg - integer(nSeg*E_start)))
    "Vector of initial temperatures"
    annotation (Dialog(tab="Initialization", enable=not use_E_start));

  //Continuous variables
  SI.MassFlowRate m_flow = port_a.m_flow
    "Mass flow rate from port_a to port_b (m_flow > 0 is design flow direction)";
  SI.Temperature T[nSeg]=tank.vol.T
    "Array of tank temperatures (index 1 is the top layer)";

  SI.HeatFlowRate Q_flow(displayUnit="MJ/s") = H_flow_top.H_flow - H_flow_bottom.H_flow
    "Charge heat flow rate (negative for discharge)";
  SI.HeatFlowRate Q_flow_loss(displayUnit="MJ/s") = tank.Ql_flow
    "Heat loss to surroundings";


  //Miscellaneous
protected
  parameter Medium.SpecificHeatCapacity cp_nominal=
      Medium.specificHeatCapacityCp(Medium.setState_pTX(Medium.p_default, 0.5*(
      T_nominal + T_reference)));
  parameter Medium.Density rho_nominal=Medium.density_pTX(
      Medium.p_default,
      0.5*(T_nominal + T_reference),
      Medium.X_default);
public
  Modelica.Fluid.Interfaces.FluidPort_a port_a(
    redeclare final package Medium = Medium,
    h_outflow(start=Medium.h_default, nominal=Medium.h_default),
    Xi_outflow(each nominal=0.01))
    "Fluid connector a (positive design flow direction is from port_a to port_b)"
    annotation (Placement(transformation(extent={{-110,-10},{-90,10}}),
        iconTransformation(extent={{-10,90},{10,110}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_b(
    redeclare final package Medium = Medium,
    h_outflow(start=Medium.h_default, nominal=Medium.h_default),
    Xi_outflow(each nominal=0.01))
    "Fluid connector b (positive design flow direction is from port_a to port_b)"
    annotation (Placement(transformation(extent={{110,-10},{90,10}}),
        iconTransformation(extent={{10,-110},{-10,-90}})));

  replaceable Buildings.Fluid.Storage.StratifiedEnhanced tank(
    redeclare package Medium = Medium,
    final m_flow_nominal=m_flow_nominal,
    VTan=abs(E_nominal/(rho_nominal*cp_nominal*(T_nominal - T_reference))),
    hTan=(100/9/Modelica.Constants.pi*tank.VTan)^(1/3),
    dIns=0.1,
    final nSeg=nSeg,
    final allowFlowReversal=true,
    final m_flow_small=m_flow_small,
    TFlu_start=T_start) "Stratified tank component" annotation (
    Dialog(tab="Advanced", group="Sub-components"),
    Placement(transformation(extent={{-20,-20},{20,20}})),
    __Dymola_choicesAllMatching=true);
  Buildings.Fluid.Sensors.EnthalpyFlowRate H_flow_top(redeclare package Medium
      = Medium, m_flow_nominal=m_flow_nominal)
    "Enthalpy flow rate into tank top"
    annotation (Placement(transformation(extent={{-70,-10},{-50,10}})));
  Buildings.Fluid.Sensors.EnthalpyFlowRate H_flow_bottom(redeclare package
      Medium = Medium, m_flow_nominal=m_flow_nominal)
    "Enthalpy flow rate out of tank bottom"
    annotation (Placement(transformation(extent={{50,-10},{70,10}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heatPort annotation (
      Placement(transformation(extent={{36,30},{56,50}}), iconTransformation(
          extent={{54,-6},{66,6}})));
  Buildings.Fluid.Sources.Boundary_pT pressurizer(
    redeclare package Medium = Medium,
    p=p_static,
    T=T_reference,
    nPorts=1) if use_presurizer "Pressurizer component" annotation (Dialog(tab="Advanced",
        group="Sub-components"), Placement(transformation(extent={{-60,-50},{-40,
            -30}})));
equation
  connect(port_a, H_flow_top.port_a)
    annotation (Line(points={{-100,0},{-70,0}}, color={0,127,255}));
  connect(H_flow_top.port_b, tank.port_a) annotation (Line(points={{-50,0},{-40,
          0},{-40,40},{0,40},{0,20}}, color={0,127,255}));
  connect(port_b, H_flow_bottom.port_b)
    annotation (Line(points={{100,0},{70,0}}, color={0,127,255}));
  connect(H_flow_bottom.port_a, tank.port_b) annotation (Line(points={{50,0},{40,
          0},{40,-40},{0,-40},{0,-20}}, color={0,127,255}));
  connect(tank.heaPorTop, heatPort)
    annotation (Line(points={{4,14.8},{4,40},{46,40}}, color={191,0,0}));
  connect(tank.heaPorSid, heatPort) annotation (Line(points={{11.2,0},{30,0},{30,
          26},{46,26},{46,40}}, color={191,0,0}));
  connect(pressurizer.ports[1], tank.port_b)
    annotation (Line(points={{-40,-40},{0,-40},{0,-20}}, color={0,127,255}));
  annotation (
    Documentation(info="", revisions="<html>
<ul>
<li>
May 20, 2026, by Rene Just Nielsen:<br/>
First implementation.
</li>
</ul>
</html>"),
    Icon(coordinateSystem(preserveAspectRatio=true, extent={{-100,-100},{100,100}}),
        graphics={
        Ellipse(
          extent={{-60,90},{60,50}},
          lineColor={0,0,0},
          fillColor={240,240,240},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-60,70},{60,-90}},
          lineColor={0,0,0},
          fillColor={240,240,240},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Rectangle(
          extent={{-60,0},{60,-90}},
          fillColor={0,128,255},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Line(
          points={{-26,-68},{-16,-72},{0,-74},{16,-72},{26,-68}},
          color={0,0,0},
          smooth=Smooth.Bezier),
        Line(points={{-26,-78},{26,-78}}, color={0,0,0}),
        Rectangle(
          extent={{-60,70},{60,0}},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Line(points={{-60,70},{-60,-90},{60,-90},{60,70}}, color={0,0,0}),
        Line(points={{-26,62},{26,62}}, color={0,0,0}),
        Line(
          points={{-26,52},{-16,56},{0,58},{16,56},{26,52}},
          color={0,0,0},
          smooth=Smooth.Bezier),
        Text(
          extent={{-100,20},{100,-20}},
          textColor={0,0,0},
          textString=DynamicSelect("", String(1e-6*Q_flow, format=".2f") +
              " MW"),
          origin={-90,0},
          rotation=90)}),
    Diagram(coordinateSystem(extent={{-100,-60},{100,60}}, grid={2,2})));
end HeatStorageTank;
