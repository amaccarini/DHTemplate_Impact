within DHTemplates.Models;

model DistrictHeatingSystem_noEleBoiler_Dispatch_noReadOut_COPconstant "System model"
  extends .Modelica.Icons.Example;
  replaceable package Medium = .Buildings.Media.Water annotation (
      choicesAllMatching=true);

  // Producers
  .DHTemplates.Components.HeatPump heatPump(
    redeclare package Medium = Medium,
    Q_flow_nominal=40000000,
    powerControl=false,
    use_P_set_in=false,
    redeclare replaceable .Modelica.Blocks.Sources.TimeTable P_set(table=[0.0,
          heatPump.P_nominal; 20,heatPump.P_nominal; 30,0; 60,0], timeScale(
          displayUnit="min") = 60),
    use_Q_flow_set_in=true,
    use_T_set_in=false,
    use_T_source_in=true)           annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=270,
        origin={-100,0})));
  .DHTemplates.Components.Producer gasBoiler(redeclare package Medium = Medium,
    Q_flow_nominal=60000000,
    use_Q_flow_set_in=true)    annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=270,
        origin={-50,0})));

  // Consumers
  .DHTemplates.Components.Consumer consumer(redeclare package Medium = Medium,
    use_Q_flow_set_in=true,
      redeclare replaceable .Modelica.Blocks.Sources.TimeTable Q_flow_set(table=
          [0.0,consumer.Q_flow_nominal; 40,consumer.Q_flow_nominal; 40,0.1*
          consumer.Q_flow_nominal; 60,0.1*consumer.Q_flow_nominal], timeScale(
          displayUnit="min") = 60)) annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=270,
        origin={140,0})));

  // Storage and transmission
  .DHTemplates.Components.HeatStorageTank heatStorageTank(redeclare package
      Medium = Medium, E_nominal( displayUnit="GJ")= 1800000000000)
    annotation (Placement(transformation(extent={{-20,-20},{20,20}})));
  .Buildings.Fluid.Movers.SpeedControlled_y pump(
    redeclare package Medium = Medium,
    energyDynamics=.Modelica.Fluid.Types.Dynamics.FixedInitial,
    per(pressure(V_flow=2*{0,consumer.m_flow_nominal/rho_nominal,1.5*consumer.m_flow_nominal
            /rho_nominal}, dp=2*{2*consumer.dp_nominal,consumer.dp_nominal,0})))
    "DH supply pump" annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={90,50})));
  replaceable .Buildings.Controls.Continuous.LimPID pid(
    k=2/1e5,
    Ti=10,
    u_s(unit="Pa", displayUnit="bar"),
    u_m(unit="Pa", displayUnit="bar")) "Differential pressure controller"
    annotation (Dialog(group="Heat flow rate control"), Placement(
        transformation(extent={{58,-2},{78,18}})));
  replaceable .Modelica.Blocks.Sources.Constant dp_set(k=consumer.dp_nominal)
    constrainedby .Modelica.Blocks.Interfaces.SO(y(unit="Pa", displayUnit="bar"))
    "Differential pressure setpoint" annotation (
    Dialog(group="Heat flow rate control"),
    Placement(transformation(extent={{28,-2},{48,18}})),
    choicesAllMatching=true);
  .Buildings.Fluid.Sensors.RelativePressure senRelPre(redeclare package Medium
      = Medium) annotation (Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=270,
        origin={120,0})));

  .Modelica.Blocks.Sources.CombiTimeTable combiTimeTable(
    tableOnFile=true,
    tableName="dispatch",
    fileName=.Modelica.Utilities.Files.loadResource("modelica://DHTemplates/Resources/dispatch_combitimetable_full_lambda_20_negdemand.txt"),
    columns={2,3,4,5,6})
    annotation (Placement(transformation(extent={{-166,-40},{-146,-20}})));
    .Modelica.Blocks.Sources.Constant const(k = 273.15 + 17) annotation(Placement(transformation(extent = {{-126,24},{-106,44}},origin = {0,0},rotation = 0)));
protected
  // Junctions
  .Buildings.Fluid.FixedResistances.Junction jun(
    redeclare package Medium = Medium,
    energyDynamics=.Modelica.Fluid.Types.Dynamics.SteadyState,
    m_flow_nominal={1000,-1000,1000},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{-4,46},{4,54}})));
  .Buildings.Fluid.FixedResistances.Junction jun1(
    redeclare package Medium = Medium,
    energyDynamics=.Modelica.Fluid.Types.Dynamics.SteadyState,
    m_flow_nominal={1000,-1000,1000},
    dp_nominal={0,0,0}) annotation (Placement(transformation(
        extent={{-4,-4},{4,4}},
        rotation=180,
        origin={0,-50})));
  .Buildings.Fluid.FixedResistances.Junction jun4(
    redeclare package Medium = Medium,
    energyDynamics=.Modelica.Fluid.Types.Dynamics.SteadyState,
    m_flow_nominal={1000,-1000,1000},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{-54,46},{-46,54}})));
  .Buildings.Fluid.FixedResistances.Junction jun5(
    redeclare package Medium = Medium,
    energyDynamics=.Modelica.Fluid.Types.Dynamics.SteadyState,
    m_flow_nominal={1000,-1000,1000},
    dp_nominal={0,0,0}) annotation (Placement(transformation(
        extent={{-4,-4},{4,4}},
        rotation=180,
        origin={-50,-50})));
  parameter Medium.Density rho_nominal=Medium.density_pTX(
      Medium.p_default,
      Medium.T_default,
      Medium.X_default);
equation
  connect(senRelPre.port_a, consumer.port_a) annotation (Line(points={{120,6},{
          120,20},{140,20},{140,10}}, color={0,127,255}));
  connect(senRelPre.port_b, consumer.port_b) annotation (Line(points={{120,-6},
          {120,-20},{140,-20},{140,-10}}, color={0,127,255}));
  connect(dp_set.y, pid.u_s)
    annotation (Line(points={{49,8},{56,8}}, color={0,0,127}));
  connect(pid.y, pump.y)
    annotation (Line(points={{79,8},{90,8},{90,38}}, color={0,0,127}));
  connect(senRelPre.p_rel, pid.u_m) annotation (Line(points={{114.6,0},{100,0},
          {100,-20},{68,-20},{68,-4}}, color={0,0,127}));
  connect(pump.port_a, jun.port_2)
    annotation (Line(points={{80,50},{4,50}}, color={0,127,255}));
  connect(jun5.port_3, gasBoiler.port_a)
    annotation (Line(points={{-50,-46},{-50,-10}}, color={0,127,255}));
  connect(jun4.port_2, jun.port_1)
    annotation (Line(points={{-46,50},{-4,50}}, color={0,127,255}));
  connect(jun5.port_2, heatPump.port_a) annotation (Line(points={{-54,-50},{
          -100,-50},{-100,-10}}, color={0,127,255}));
    connect(combiTimeTable.y[1],heatPump.Q_flow_set_in) annotation(Line(points = {{-145,-30},{-106,-30},{-106,-12}},color = {0,0,127}));
    connect(gasBoiler.Q_flow_set_in,combiTimeTable.y[2]) annotation(Line(points = {{-56,-12},{-56,-30},{-145,-30}},color = {0,0,127}));
    connect(consumer.Q_flow_set_in,combiTimeTable.y[5]) annotation(Line(points = {{146,12},{146,70},{-139,70},{-139,-30},{-145,-30}},color = {0,0,127}));
    connect(heatPump.port_b,jun4.port_1) annotation(Line(points = {{-100,10},{-100,50},{-54,50}},color = {0,127,255}));
    connect(gasBoiler.port_b,jun4.port_3) annotation(Line(points = {{-50,10},{-50,46}},color = {0,127,255}));
    connect(heatStorageTank.port_a,jun.port_3) annotation(Line(points = {{0,20},{0,46}},color = {0,127,255}));
    connect(jun1.port_3,heatStorageTank.port_b) annotation(Line(points = {{0,-46},{0,-20}},color = {0,127,255}));
    connect(jun5.port_1,jun1.port_2) annotation(Line(points = {{-46,-50},{-4,-50}},color = {0,127,255}));
    connect(pump.port_b,consumer.port_a) annotation(Line(points = {{100,50},{140,50},{140,10}},color = {0,127,255}));
    connect(jun1.port_1,consumer.port_b) annotation(Line(points = {{4,-50},{140,-50},{140,-10}},color = {0,127,255}));
    connect(const.y,heatPump.T_source_in) annotation(Line(points = {{-105,34},{-82,34},{-82,0},{-88,0}},color = {0,0,127}));
  annotation (
    Diagram(coordinateSystem(extent={{-160,-60},{160,60}}, grid={2,2})),
    experiment(StopTime=31536000, __Dymola_Algorithm="Dassl"),
    Documentation(revisions="<html>
<ul>
<li>
August 20, 2026, by Rene Just Nielsen:<br>
Value crosses added to simulation model.
</li>
<li>
May 20, 2026, by Rene Just Nielsen:<br>
First implementation.
</li>
</ul>
</html>", figures={Figure(
          title="Plot results",
          plots={Plot(
            curves={Curve(
              x=time,
              y=heatPump.Q_flow,
              legend="Heat pump heat flow rate"),Curve(
              x=time,
              y=electrodeBoiler.Q_flow,
              legend="Electrode boiler heat flow rate"),Curve(
              x=time,
              y=gasBoiler.Q_flow,
              legend="Gas boiler heat flow rate"),Curve(
              x=time,
              y=consumer.Q_flow,
              legend="Consumer heat flow rate"),Curve(
              x=time,
              y=heatStorageTank.Q_flow,
              legend="Heat storage tank charge rate")},
            x=Axis(label="", unit="min"),
            y=Axis(label="", unit="MW"))})}));
end DistrictHeatingSystem_noEleBoiler_Dispatch_noReadOut_COPconstant;
