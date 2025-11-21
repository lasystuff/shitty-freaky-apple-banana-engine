package funkin.util;

class ReflectUtil
{
	public static inline function copyToObject(data:Dynamic, target:Dynamic):Dynamic
	{
		for (field in Reflect.fields(data))
		{
			if (Reflect.hasField(target, field) && !Reflect.isFunction(Reflect.field(target, field)))
			{
				Reflect.setProperty(target, field, Reflect.field(data, field));
			}
		}

		return target;
	}
}