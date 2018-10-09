

class AA {
    // private ll = 1;
	say() {
		console.log("sssssssssssssss");
	}
}

class BB {
	run() {
		console.log("ddddddddddddddddd");
	}
}

function applyMixins(derivedCtor: any, baseCtors: any[]) {
    baseCtors.forEach(baseCtor => {
        Object.getOwnPropertyNames(baseCtor.prototype).forEach(name => {
            derivedCtor.prototype[name] = baseCtor.prototype[name];
        });
    });
}

function create(key: string, ...mixins: (new () => any)[]): any {
	if (mixins && mixins.length) {
        class temp {
            constructor(key: string) {
                
            }
        }

        applyMixins(temp, mixins);
        const result = new temp(key);
        for (const mixin of mixins) {
            mixin.bind(result)();
        }
        return result;
    }
}

let opa :AA & BB = create("cc", AA, BB);
opa.say();
opa.run();

