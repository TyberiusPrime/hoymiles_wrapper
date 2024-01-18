from hoymiles_modbus.client import HoymilesModbusTCP
from hoymiles_modbus.datatypes import MicroinverterType

from hoymiles_mqtt import MI_ENTITIES, PORT_ENTITIES
from hoymiles_mqtt.ha import HassMqtt
from hoymiles_mqtt.mqtt import MqttPublisher
from hoymiles_mqtt.runners import HoymilesQueryJob, run_periodic_job

import os


def main():
    mqtt_builder = HassMqtt(
        mi_entities=[],
        port_entities=[],
        expire_after=0,
    )
    microinverter_type = getattr(MicroinverterType, "HM")
    modbus_client = HoymilesModbusTCP(
        host=os.environ['DTU_HOST'],
        port=502,
        microinverter_type=microinverter_type,
        unit_id=1,
    )
    modbus_client.comm_params.timeout = 30
    modbus_client.comm_params.retries = 1
    modbus_client.comm_params.retry_on_empty = True
    modbus_client.comm_params.close_comm_on_error = True
    modbus_client.comm_params.strict = True
    modbus_client.comm_params.reconnect_delay = 5

    mqtt_publisher = MqttPublisher(
        mqtt_broker=os.environ['MQTT_HOST'],
        mqtt_port=int(os.environ['MQTT_PORT']),
        mqtt_user=os.environ['MQTT_USERNAME'],

        mqtt_password=os.environ['MQTT_PASSWORD'],

    )
    query_job = HoymilesQueryJob(
        mqtt_builder=mqtt_builder,
        mqtt_publisher=mqtt_publisher,
        modbus_client=modbus_client,
    )
    #run_periodic_job(period=options.query_period, job=query_job.execute)
    query_job.execute()
