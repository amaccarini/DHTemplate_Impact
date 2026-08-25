within DHTemplates.Models;
model DistrictHeatingSystem_singleTemperature
  "Single temperature level district heating system comprising, electrode boiler, heat pump, storage, transmission and consumer"
  extends Modelica.Icons.Example;

  package Medium = Buildings.Media.Water "DH water";

  parameter Modelica.Units.SI.Temperature T_hot_nominal=90 + 273.15
    "Nominal hot temperature";
  parameter Modelica.Units.SI.Temperature T_return_nominal=40 + 273.15
    "Nominal DH return temperature";

  parameter Modelica.Units.SI.HeatFlowRate Q_flow_EB=40e6
    "Nominal heat flow rate of electrode boiler";
  parameter Modelica.Units.SI.MassFlowRate m_flow_EB=Q_flow_EB/(cp_default*(
      T_hot_nominal - T_return_nominal))
    "Nominal mass flow rate through electrode boiler";
  parameter Modelica.Units.SI.HeatFlowRate Q_flow_HP=70e6
    "Nominal heat flow rate of heat pump";
  parameter Modelica.Units.SI.MassFlowRate m_flow_HP=Q_flow_HP/(cp_default*(
      T_hot_nominal - T_return_nominal))
    "Nominal mass flow rate through heat pump";
  parameter Modelica.Units.SI.HeatFlowRate Q_flow_con=-80e6
    "Nominal heat flow rate of consumer";
  parameter Modelica.Units.SI.MassFlowRate m_flow_con=abs(Q_flow_con/(
      cp_default*(T_hot_nominal - T_return_nominal)))
    "Nominal mass flow rate through consumer";
  parameter Modelica.Units.SI.MassFlowRate m_flow_tan=m_flow_EB + m_flow_HP +
      m_flow_con "Nominal mass flow rate through tank";
protected
  parameter Medium.SpecificHeatCapacity cp_default=
      Medium.specificHeatCapacityCp(Medium.setState_pT(Medium.p_default, Medium.T_default))
    "Default isobaric specific heat capacity";
public
  Buildings.Fluid.HeatExchangers.Heater_T eleBoi(
    redeclare package Medium = Medium,
    m_flow_nominal=eleBoi.QMax_flow/(4186*(90 - 40)),
    dp_nominal=5e4,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    QMax_flow=40e6) "Electrode boiler" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-150,0})));
  Buildings.Fluid.Movers.SpeedControlled_y movEleBoi(
    redeclare package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    per(pressure(V_flow={0,m_flow_EB/Medium.d_const,1.5*m_flow_EB/Medium.d_const},
          dp={2*eleBoi.dp_nominal,eleBoi.dp_nominal,0}))) annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-150,-40})));
  Buildings.Fluid.HeatExchangers.Heater_T heaPum(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_HP,
    dp_nominal=5e4,
    QMax_flow=Q_flow_HP) "Heat pump" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-30,0})));
  Buildings.Fluid.Movers.SpeedControlled_y movHeaPum(
    redeclare package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    per(pressure(V_flow={0,m_flow_HP/Medium.d_const,1.5*m_flow_HP/Medium.d_const},
          dp={2*heaPum.dp_nominal,heaPum.dp_nominal,0}))) annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-30,-40})));
  Buildings.Fluid.Movers.SpeedControlled_y movDHTra(
    redeclare package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    per(pressure(V_flow={0,2*m_flow_con/Medium.d_const,3*m_flow_con/Medium.d_const},
          dp={4*(val.dp_nominal + val.dpFixed_nominal),2*(val.dp_nominal + val.dpFixed_nominal),
            0}))) "DH transmission pump (supply)" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={90,30})));
  Buildings.Fluid.Storage.StratifiedEnhanced tan(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_tan,
    VTan=40000,
    hTan=40,
    dIns=1,
    nSeg=40,
    TFlu_start=cat(
        1,
        T_hot_nominal*ones(integer(tan.nSeg/2)),
        T_return_nominal*ones(integer(tan.nSeg/2)))

) annotation (Placement(transformation(extent={{10,-20},{30,0}})));
  Buildings.Fluid.FixedResistances.Junction jun(
    redeclare package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    m_flow_nominal={1000,1000,1000},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{-40,20},{-20,40}})));
  Buildings.Fluid.FixedResistances.Junction jun1(
    redeclare package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    m_flow_nominal={1000,1000,1000},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{10,20},{30,40}})));
  Buildings.Fluid.FixedResistances.Junction jun2(
    redeclare package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    m_flow_nominal={1000,1000,1000},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{-20,-70},{-40,-90}})));
  Buildings.Fluid.FixedResistances.Junction jun3(
    redeclare package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    m_flow_nominal={1000,1000,1000},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{30,-70},{10,-90}})));
  Buildings.Fluid.HeatExchangers.SensibleCooler_T con(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_con,
    dp_nominal=0,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    tau=30) "Consumer" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={140,-40})));
  Buildings.Fluid.Actuators.Valves.TwoWayLinear val(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_con,
    dpValve_nominal=1e4,
    dpFixed_nominal=9e4) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={140,0})));
  Buildings.Fluid.Sources.Boundary_pT bou(
    p=tan.hTan*Modelica.Constants.g_n*Medium.d_const,
    T=T_return_nominal,
    nPorts=1,
    redeclare package Medium = Medium) annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=90,
        origin={40,-50})));
  Buildings.Fluid.Sensors.RelativePressure senRelPre(redeclare package Medium
      = Medium) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={110,-26})));
  Modelica.Blocks.Sources.Constant const(k=T_hot_nominal) annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={-176,0})));
  Modelica.Blocks.Sources.Constant const1(k=T_hot_nominal) annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={-56,0})));
  Modelica.Blocks.Sources.Constant const2(k=T_return_nominal) annotation (
      Placement(transformation(
        extent={{10,10},{-10,-10}},
        rotation=270,
        origin={168,-40})));
  Buildings.Controls.Continuous.LimPID conPID(k=1/Q_flow_EB)
    annotation (Placement(transformation(extent={{-206,-30},{-186,-50}})));
  Modelica.Blocks.Sources.Constant const3(k=Q_flow_EB)
    annotation (Placement(transformation(extent={{-240,-50},{-220,-30}})));
  Buildings.Controls.Continuous.LimPID conPID1(k=1/Q_flow_HP)
    annotation (Placement(transformation(extent={{-86,-30},{-66,-50}})));
  Modelica.Blocks.Sources.Ramp ramp(
    height=-0.9*Q_flow_HP,
    duration(displayUnit="min") = 300,
    offset=Q_flow_HP,
    startTime(displayUnit="min") = 300)
    annotation (Placement(transformation(extent={{-120,-50},{-100,-30}})));
  Buildings.Controls.Continuous.LimPID conPID2(k=abs(1/Q_flow_con),
      reverseActing=false) annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=180,
        origin={190,0})));
  Modelica.Blocks.Sources.Constant const5(k=Q_flow_con)
    annotation (Placement(transformation(extent={{230,-10},{210,10}})));
  Buildings.Controls.Continuous.LimPID conPID3(k=1e-5) annotation (Placement(
        transformation(
        extent={{10,10},{-10,-10}},
        rotation=180,
        origin={70,70})));
  Modelica.Blocks.Sources.Constant const6(k=val.dp_nominal + val.dpFixed_nominal)
    annotation (Placement(transformation(extent={{28,60},{48,80}})));
equation
  connect(movEleBoi.port_b, eleBoi.port_a)
    annotation (Line(points={{-150,-30},{-150,-10}}, color={0,127,255}));
  connect(movHeaPum.port_b, heaPum.port_a)
    annotation (Line(points={{-30,-30},{-30,-10}}, color={0,127,255}));
  connect(val.port_b, con.port_a)
    annotation (Line(points={{140,-10},{140,-30}}, color={0,127,255}));
  connect(tan.port_a, jun1.port_3)
    annotation (Line(points={{20,0},{20,20}}, color={0,127,255}));
  connect(tan.port_b, jun3.port_3)
    annotation (Line(points={{20,-20},{20,-70}}, color={0,127,255}));
  connect(tan.port_b, bou.ports[1]) annotation (Line(points={{20,-20},{20,-30},
          {40,-30},{40,-40}}, color={0,127,255}));
  connect(eleBoi.port_b, jun.port_1) annotation (Line(points={{-150,10},{-150,
          30},{-40,30}}, color={0,127,255}));
  connect(jun.port_2, jun1.port_1)
    annotation (Line(points={{-20,30},{10,30}}, color={0,127,255}));
  connect(heaPum.port_b, jun.port_3)
    annotation (Line(points={{-30,10},{-30,20}}, color={0,127,255}));
  connect(movEleBoi.port_a, jun2.port_2) annotation (Line(points={{-150,-50},{-150,
          -80},{-40,-80}}, color={0,127,255}));
  connect(jun2.port_3, movHeaPum.port_a)
    annotation (Line(points={{-30,-70},{-30,-50}}, color={0,127,255}));
  connect(jun2.port_1, jun3.port_2)
    annotation (Line(points={{-20,-80},{10,-80}}, color={0,127,255}));
  connect(jun1.port_2, movDHTra.port_a)
    annotation (Line(points={{30,30},{80,30}}, color={0,127,255}));
  connect(movDHTra.port_b, val.port_a)
    annotation (Line(points={{100,30},{140,30},{140,10}}, color={0,127,255}));
  connect(jun3.port_1, con.port_b) annotation (Line(points={{30,-80},{140,-80},
          {140,-50}}, color={0,127,255}));
  connect(senRelPre.port_a, val.port_a) annotation (Line(points={{110,-16},{110,
          20},{140,20},{140,10}}, color={0,127,255}));
  connect(senRelPre.port_b, con.port_b) annotation (Line(points={{110,-36},{110,
          -60},{140,-60},{140,-50}}, color={0,127,255}));
  connect(const.y, eleBoi.TSet) annotation (Line(points={{-176,-11},{-176,-20},
          {-158,-20},{-158,-12}}, color={0,0,127}));
  connect(const1.y, heaPum.TSet) annotation (Line(points={{-56,-11},{-56,-20},{
          -38,-20},{-38,-12}}, color={0,0,127}));
  connect(const2.y, con.TSet) annotation (Line(points={{168,-29},{168,-20},{148,
          -20},{148,-28}}, color={0,0,127}));
  connect(conPID.y, movEleBoi.y)
    annotation (Line(points={{-185,-40},{-162,-40}}, color={0,0,127}));
  connect(conPID.u_m, eleBoi.Q_flow) annotation (Line(points={{-196,-28},{-196,
          20},{-158,20},{-158,11}}, color={0,0,127}));
  connect(const3.y, conPID.u_s)
    annotation (Line(points={{-219,-40},{-208,-40}}, color={0,0,127}));
  connect(ramp.y, conPID1.u_s)
    annotation (Line(points={{-99,-40},{-88,-40}}, color={0,0,127}));
  connect(conPID1.y, movHeaPum.y)
    annotation (Line(points={{-65,-40},{-42,-40}}, color={0,0,127}));
  connect(heaPum.Q_flow, conPID1.u_m) annotation (Line(points={{-38,11},{-38,20},
          {-76,20},{-76,-28}}, color={0,0,127}));
  connect(const5.y, conPID2.u_s)
    annotation (Line(points={{209,0},{202,0}}, color={0,0,127}));
  connect(val.y, conPID2.y)
    annotation (Line(points={{152,0},{179,0}}, color={0,0,127}));
  connect(con.Q_flow, conPID2.u_m) annotation (Line(points={{148,-51},{148,-60},
          {190,-60},{190,-12}}, color={0,0,127}));
  connect(const6.y, conPID3.u_s)
    annotation (Line(points={{49,70},{58,70}}, color={0,0,127}));
  connect(conPID3.y, movDHTra.y)
    annotation (Line(points={{81,70},{90,70},{90,42}}, color={0,0,127}));
  connect(senRelPre.p_rel, conPID3.u_m)
    annotation (Line(points={{101,-26},{70,-26},{70,58}}, color={0,0,127}));
  annotation (
    experiment(StopTime=900, __Dymola_Algorithm="Dassl"),
    Diagram(coordinateSystem(extent={{-240,-100},{240,100}}, grid={2,2})),
    Documentation(revisions="<html>
<ul>
<li>
April 15, 2026, by Rene Just Nielsen:<br>
First implementation of a \"flat\" model.
</li>
</ul>
</html>"));
end DistrictHeatingSystem_singleTemperature;
