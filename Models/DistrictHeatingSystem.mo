within DHTemplates.Models;
model DistrictHeatingSystem "System model"
  extends Modelica.Icons.Example;
  replaceable package Medium = Buildings.Media.Water annotation (
      choicesAllMatching=true);

  // Producers
  Components.HeatPump heatPump(
    redeclare package Medium = Medium,
    Q_flow_nominal=40000000,
    use_P_set_in=false,
    redeclare replaceable Modelica.Blocks.Sources.TimeTable P_set(table=[0.0,
          heatPump.P_nominal; 20,heatPump.P_nominal; 30,0; 60,0], timeScale(
          displayUnit="min") = 60)) annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=270,
        origin={-140,0})));
  DHTemplates.Components.Producer electrodeBoiler(
    redeclare package Medium = Medium,
    Q_flow_nominal=30000000,
    redeclare replaceable Modelica.Blocks.Sources.TimeTable Q_flow_set(table=[
          0.0,0; 20,0; 25,electrodeBoiler.Q_flow_nominal; 60,electrodeBoiler.Q_flow_nominal],
        timeScale(displayUnit="min") = 60)) annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=270,
        origin={-90,0})));
  Components.Producer gasBoiler(redeclare package Medium = Medium,
      Q_flow_nominal=60000000) annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=270,
        origin={-50,0})));

  // Consumers
  DHTemplates.Components.Consumer consumer(redeclare package Medium = Medium,
      redeclare replaceable Modelica.Blocks.Sources.TimeTable Q_flow_set(table=
          [0.0,consumer.Q_flow_nominal; 40,consumer.Q_flow_nominal; 40,0.1*
          consumer.Q_flow_nominal; 60,0.1*consumer.Q_flow_nominal], timeScale(
          displayUnit="min") = 60)) annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=270,
        origin={140,0})));

  // Storage and transmission
  DHTemplates.Components.HeatStorageTank heatStorageTank(redeclare package
      Medium = Medium, E_nominal( displayUnit="GJ")= 1800000000000)
    annotation (Placement(transformation(extent={{-20,-20},{20,20}})));
  Buildings.Fluid.Movers.SpeedControlled_y pump(
    redeclare package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    per(pressure(V_flow=2*{0,consumer.m_flow_nominal/rho_nominal,1.5*consumer.m_flow_nominal
            /rho_nominal}, dp=2*{2*consumer.dp_nominal,consumer.dp_nominal,0})))
    "DH supply pump" annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={90,50})));
  replaceable Buildings.Controls.Continuous.LimPID pid(
    k=2/1e5,
    Ti=10,
    u_s(unit="Pa", displayUnit="bar"),
    u_m(unit="Pa", displayUnit="bar")) "Differential pressure controller"
    annotation (Dialog(group="Heat flow rate control"), Placement(
        transformation(extent={{58,-2},{78,18}})));
  replaceable Modelica.Blocks.Sources.Constant dp_set(k=consumer.dp_nominal)
    constrainedby Modelica.Blocks.Interfaces.SO(y(unit="Pa", displayUnit="bar"))
    "Differential pressure setpoint" annotation (
    Dialog(group="Heat flow rate control"),
    Placement(transformation(extent={{28,-2},{48,18}})),
    choicesAllMatching=true);
  Buildings.Fluid.Sensors.RelativePressure senRelPre(redeclare package Medium
      = Medium) annotation (Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=270,
        origin={120,0})));

  // Value crosses
  Sensors.ValueCross valueCross1
    annotation (Placement(transformation(extent={{-134,20},{-106,40}})));
  Sensors.ValueCross valueCross2
    annotation (Placement(transformation(extent={{-84,20},{-56,40}})));
  Sensors.ValueCross valueCross3
    annotation (Placement(transformation(extent={{-40,-50},{-12,-30}})));
  Sensors.ValueCross valueCross4
    annotation (Placement(transformation(extent={{-44,20},{-16,40}})));
  Sensors.ValueCross valueCross5
    annotation (Placement(transformation(extent={{6,20},{34,40}})));
  Sensors.ValueCross valueCross6
    annotation (Placement(transformation(extent={{106,20},{134,40}})));
  Sensors.ValueCross valueCross7
    annotation (Placement(transformation(extent={{106,-40},{134,-20}})));
  Sensors.ValueCross valueCross8
    annotation (Placement(transformation(extent={{6,-42},{34,-22}})));

protected
  // Junctions
  Buildings.Fluid.FixedResistances.Junction jun(
    redeclare package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    m_flow_nominal={1000,-1000,1000},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{-4,46},{4,54}})));
  Buildings.Fluid.FixedResistances.Junction jun1(
    redeclare package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    m_flow_nominal={1000,-1000,1000},
    dp_nominal={0,0,0}) annotation (Placement(transformation(
        extent={{-4,-4},{4,4}},
        rotation=180,
        origin={0,-50})));
  Buildings.Fluid.FixedResistances.Junction jun2(
    redeclare package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    m_flow_nominal={1000,-1000,1000},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{-94,46},{-86,54}})));
  Buildings.Fluid.FixedResistances.Junction jun3(
    redeclare package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    m_flow_nominal={1000,-1000,1000},
    dp_nominal={0,0,0}) annotation (Placement(transformation(
        extent={{-4,-4},{4,4}},
        rotation=180,
        origin={-90,-50})));
  Buildings.Fluid.FixedResistances.Junction jun4(
    redeclare package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    m_flow_nominal={1000,-1000,1000},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{-54,46},{-46,54}})));
  Buildings.Fluid.FixedResistances.Junction jun5(
    redeclare package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    m_flow_nominal={1000,-1000,1000},
    dp_nominal={0,0,0}) annotation (Placement(transformation(
        extent={{-4,-4},{4,4}},
        rotation=180,
        origin={-50,-50})));
  Sensors.MultiSensor multiSensor1(redeclare package Medium = Medium)
    annotation (Placement(transformation(
        extent={{-4,4},{4,-4}},
        rotation=90,
        origin={-140,30})));
  Sensors.MultiSensor multiSensor2(redeclare package Medium = Medium)
    annotation (Placement(transformation(
        extent={{-4,4},{4,-4}},
        rotation=90,
        origin={-90,30})));
  Sensors.MultiSensor multiSensor3(redeclare package Medium = Medium)
    annotation (Placement(transformation(
        extent={{-4,4},{4,-4}},
        rotation=180,
        origin={-26,-50})));
  Sensors.MultiSensor multiSensor4(redeclare package Medium = Medium)
    annotation (Placement(transformation(
        extent={{-4,4},{4,-4}},
        rotation=90,
        origin={-50,30})));
  Sensors.MultiSensor multiSensor5(redeclare package Medium = Medium)
    annotation (Placement(transformation(
        extent={{4,4},{-4,-4}},
        rotation=90,
        origin={0,30})));
  Sensors.MultiSensor multiSensor6(redeclare package Medium = Medium)
    annotation (Placement(transformation(
        extent={{4,-4},{-4,4}},
        rotation=90,
        origin={140,30})));
  Sensors.MultiSensor multiSensor7(redeclare package Medium = Medium)
    annotation (Placement(transformation(
        extent={{4,-4},{-4,4}},
        rotation=90,
        origin={140,-30})));
  Sensors.MultiSensor multiSensor8(redeclare package Medium = Medium)
    annotation (Placement(transformation(
        extent={{-4,4},{4,-4}},
        rotation=90,
        origin={0,-32})));
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
  connect(jun3.port_2, heatPump.port_a) annotation (Line(points={{-94,-50},{-140,
          -50},{-140,-10}}, color={0,127,255}));
  connect(jun5.port_3, gasBoiler.port_a)
    annotation (Line(points={{-50,-46},{-50,-10}}, color={0,127,255}));
  connect(jun4.port_2, jun.port_1)
    annotation (Line(points={{-46,50},{-4,50}}, color={0,127,255}));
  connect(jun3.port_3, electrodeBoiler.port_a)
    annotation (Line(points={{-90,-46},{-90,-10}}, color={0,127,255}));
  connect(jun2.port_2, jun4.port_1)
    annotation (Line(points={{-86,50},{-54,50}}, color={0,127,255}));
  connect(jun3.port_1, jun5.port_2)
    annotation (Line(points={{-86,-50},{-54,-50}}, color={0,127,255}));
  connect(heatPump.port_b, multiSensor1.port_a)
    annotation (Line(points={{-140,10},{-140,26}}, color={0,127,255}));
  connect(multiSensor1.port_b, jun2.port_1) annotation (Line(points={{-140,34},
          {-140,50},{-94,50}}, color={0,127,255}));
  connect(electrodeBoiler.port_b, multiSensor2.port_a)
    annotation (Line(points={{-90,10},{-90,26}}, color={0,127,255}));
  connect(multiSensor2.port_b, jun2.port_3)
    annotation (Line(points={{-90,34},{-90,46}}, color={0,127,255}));
  connect(valueCross1.multiSensorPort, multiSensor1.multiSensorPort)
    annotation (Line(
      points={{-120,30},{-138,30}},
      color={0,0,0},
      pattern=LinePattern.Solid,
      thickness=0));
  connect(multiSensor2.multiSensorPort, valueCross2.multiSensorPort)
    annotation (Line(
      points={{-88,30},{-70,30}},
      color={0,0,0},
      pattern=LinePattern.Solid,
      thickness=0));
  connect(multiSensor3.multiSensorPort, valueCross3.multiSensorPort)
    annotation (Line(
      points={{-26,-48},{-26,-40}},
      color={0,0,0},
      pattern=LinePattern.Solid,
      thickness=0));
  connect(jun5.port_1, multiSensor3.port_b)
    annotation (Line(points={{-46,-50},{-30,-50}}, color={0,127,255}));
  connect(multiSensor3.port_a, jun1.port_2)
    annotation (Line(points={{-22,-50},{-4,-50}}, color={0,127,255}));
  connect(multiSensor4.multiSensorPort, valueCross4.multiSensorPort)
    annotation (Line(
      points={{-48,30},{-30,30}},
      color={0,0,0},
      pattern=LinePattern.Solid,
      thickness=0));
  connect(gasBoiler.port_b, multiSensor4.port_a)
    annotation (Line(points={{-50,10},{-50,26}}, color={0,127,255}));
  connect(multiSensor4.port_b, jun4.port_3)
    annotation (Line(points={{-50,34},{-50,46}}, color={0,127,255}));
  connect(multiSensor5.multiSensorPort, valueCross5.multiSensorPort)
    annotation (Line(
      points={{2,30},{20,30}},
      color={0,0,0},
      pattern=LinePattern.Solid,
      thickness=0));
  connect(jun.port_3, multiSensor5.port_a)
    annotation (Line(points={{0,46},{0,34}}, color={0,127,255}));
  connect(multiSensor5.port_b, heatStorageTank.port_a)
    annotation (Line(points={{0,26},{0,20}}, color={0,127,255}));
  connect(multiSensor6.multiSensorPort, valueCross6.multiSensorPort)
    annotation (Line(
      points={{138,30},{120,30}},
      color={0,0,0},
      pattern=LinePattern.Solid,
      thickness=0));
  connect(pump.port_b, multiSensor6.port_a)
    annotation (Line(points={{100,50},{140,50},{140,34}}, color={0,127,255}));
  connect(multiSensor6.port_b, consumer.port_a)
    annotation (Line(points={{140,26},{140,10}}, color={0,127,255}));
  connect(multiSensor7.multiSensorPort, valueCross7.multiSensorPort)
    annotation (Line(
      points={{138,-30},{120,-30}},
      color={0,0,0},
      pattern=LinePattern.Solid,
      thickness=0));
  connect(jun1.port_1, multiSensor7.port_b)
    annotation (Line(points={{4,-50},{140,-50},{140,-34}}, color={0,127,255}));
  connect(multiSensor7.port_a, consumer.port_b)
    annotation (Line(points={{140,-26},{140,-10}}, color={0,127,255}));
  connect(multiSensor8.multiSensorPort, valueCross8.multiSensorPort)
    annotation (Line(
      points={{2,-32},{20,-32}},
      color={0,0,0},
      pattern=LinePattern.Solid,
      thickness=0));
  connect(heatStorageTank.port_b, multiSensor8.port_b)
    annotation (Line(points={{0,-20},{0,-28}}, color={0,127,255}));
  connect(multiSensor8.port_a, jun1.port_3)
    annotation (Line(points={{0,-36},{0,-46}}, color={0,127,255}));
  annotation (
    Diagram(coordinateSystem(extent={{-160,-60},{160,60}}, grid={2,2})),
    experiment(StopTime=3600, __Dymola_Algorithm="Dassl"),
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
end DistrictHeatingSystem;
