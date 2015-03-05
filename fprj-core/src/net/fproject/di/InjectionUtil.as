package net.fproject.di
{
	import org.as3commons.reflect.AbstractMember;
	import org.as3commons.reflect.Metadata;
	import org.as3commons.reflect.Method;
	import org.as3commons.reflect.Type;

	public class InjectionUtil
	{
		
		/**
		 * Search metadata value for a member of a class by its <code>id</code> property.
		 * @param source the metadata source to search. This can be a class, an instance object of a class
		 * or an instance of org.as3commons.reflect.Type
		 * @param member the member name/id or the member object.
		 * If this value is the member itself, them member must have an <code>id</code> property.
		 * @param metadataName the metadata name to search, should be in lower-case
		 * @param argumentName the metadata argument name to search, should be in lower-case
		 * @return If no metadata found, <code>null</code> is returned.<br/>
		 * If only one metadata found and the metadata has only one argument,
		 * the value of that argument is returned.<br/>
		 * If several metadata found and <code>argumentName</code> is not specified,
		 * an array of <code>org.as3commons.reflect.Metadata</code> objects is returned<br/>
		 * If several metadata found and <code>argumentName</code> is specified,
		 * an array of values associated with that argument is returned<br/>
		 */
		public static function findMemberMetadataValue(source:*, member:Object, 
													   metadataName:String, argumentName:String=null):Object
		{
			if(member is String)
				var memberId:String = member as String;
			else if(member != null && member.hasOwnProperty("id"))
				memberId = member.id;
			if(memberId == null)
				return null;
			
			if(source is Type)
				var type:Type = Type(source);
			else if(source is Class)
				type = Type.forClass(source);
			else
				type = Type.forInstance(source);
			
			var members:Array = type.variables.concat(type.accessors);
			var a:Array = [];
			for each (var m:AbstractMember in members)
			{ 
				if(m.name == memberId)
				{
					for each (var metadata:Metadata in m.metadata)
					{
						if(metadata.name == metadataName.toLowerCase())
						{
							if(argumentName == null)
								a.push(metadata);
							else if(metadata.hasArgumentWithKey(argumentName))
								a.push(metadata.getArgument(argumentName).value);
						}
					}
					break;
				}
			}
			
			if(a.length == 0)
				return null;
			
			if(a.length == 1)
			{
				if(a[0] is Metadata && Metadata(a[0]).arguments.length == 1)
					return Metadata(a[0]).arguments[0].value;
				else
					return a[0];
			}
			
			return a;
		}
		
		/**
		 * Search metadata value for a class by its <code>id</code> property.
		 * @param source the metadata source to search. This can be a class, an instance object of a class
		 * or an instance of org.as3commons.reflect.Type
		 * @param metadataName the metadata name to search, should be in lower-case
		 * @param argumentName the metadata argument name to search, should be in lower-case
		 * @return The returned value follows this rule:
		 * <ul>
		 * <li>If no metadata found, <code>null</code> is returned.</li>
		 * <li>If only one metadata found and the metadata has only one argument or <code>argumentName</code> is not null,
		 * the value of that argument is returned.</li>
		 * <li>If only one metadata found and the metadata has more than one argument,
		 * an instance of org.as3commons.reflect.Metadata is returned.</li>
		 * <li>If several metadata found and <code>argumentName</code> is not specified,
		 * an array of <code>org.as3commons.reflect.Metadata</code> objects is returned</li>
		 * <li>If several metadata found and <code>argumentName</code> is specified,
		 * an array of values associated with that argument is returned
		 * </ul>
		 */
		public static function findClassMetadataValue(source:*, metadataName:String, argumentName:String=null):Object
		{
			if(source is Type)
				var type:Type = Type(source);
			else if(source is Class)
				type = Type.forClass(source);
			else
				type = Type.forInstance(source);
			
			var metaArray:Array = getAllExtendsClassMetadata(type);
			var a:Array = [];
			for each (var metadata:Metadata in metaArray)
			{
				if(metadata.name == metadataName.toLowerCase())
				{
					if(argumentName == null)
						a.push(metadata);
					else if(metadata.hasArgumentWithKey(argumentName))
						a.push(metadata.getArgument(argumentName).value);
				}
			}
			
			if(a.length == 0)
				return null;
			
			if(a.length == 1)
			{
				if(a[0] is Metadata && Metadata(a[0]).arguments.length == 1)
					return Metadata(a[0]).arguments[0].value;
				else
					return a[0];
			}
			
			return a;
		}
		
		public static function getAllExtendsClassMethods(type:Type):Array
		{
			var methods:Array = type.methods;
			var nameToMethod:Object = {};
			for each (var method:Method in methods)
			{
				nameToMethod[method.name] = true;
			}
			for each(var c:String in type.extendsClasses)
			{
				var t:Type = Type.forName(c);
				for each (method in t.methods)
				{
					if(nameToMethod[method.name] == undefined)
					{
						nameToMethod[method.name] = true;
						methods.push(method);
					}
				}
			}
			
			return methods;
		}
		
		internal static function getAllExtendsClassMetadata(type:Type):Array
		{
			var a:Array = type.metadata;
			for each(var c:String in type.extendsClasses)
			{
				var t:Type = Type.forName(c);
				a = a.concat(t.metadata);
			}
			
			return a;
		}
	}
}